
world = {}

function world.generate()
	for _, v in pairs(objects.client.worldEdges) do
		v.fixture = love.physics.newFixture(v.body, v.shape, 1)
		v.fixture:setUserData{type='wall'}
	end

	local mapCanv = love.graphics.newCanvas(worldSize.x, worldSize.y)
	local airCanv = love.graphics.newCanvas(worldSize.x, worldSize.y)
	local sunCanv = love.graphics.newCanvas(worldSize.x, worldSize.y)
	love.graphics.setCanvas(airCanv)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', 0, 0, worldSize.x, worldSize.y)
	love.graphics.setCanvas(sunCanv)
	love.graphics.rectangle('fill', 0, 0, worldSize.x, worldSize.y)
	local quads = {}
	local tileset = tileMap.tilesets[1]
	for y=0, tileset.imageheight-1, tileset.tileheight do
		for x=0, tileset.imagewidth-1, tileset.tilewidth do
			table.insert(quads, love.graphics.newQuad(x, y, tileset.tilewidth, tileset.tileheight, tileset.imagewidth, tileset.imageheight))
		end
	end
	physTiles = {}
	for _, layer in ipairs(tileMap.layers) do
		for y=0, tileMap.height-1 do
			for x=0, tileMap.width-1 do
				local idx = y*tileMap.width + x + 1
				if layer.data[idx] ~= 0 then
					if layer.name == 'main' then
						physTiles[x .. ',' .. y] = true
						love.graphics.setCanvas(airCanv)
						love.graphics.setColor(0, 0, 0)
						love.graphics.rectangle('fill', x*tileMap.tilewidth, y*tileMap.tileheight, tileMap.tilewidth, tileMap.tileheight)
					end
					love.graphics.setCanvas(sunCanv)
					love.graphics.setColor(0, 0, 0)
					love.graphics.rectangle('fill', x*tileMap.tilewidth, y*tileMap.tileheight, tileMap.tilewidth, tileMap.tileheight)
					love.graphics.setCanvas(mapCanv)
					love.graphics.setColor(255, 255, 255)
					love.graphics.draw(gfx.enviro.tileSheet, quads[layer.data[idx]], x*tileMap.tilewidth, y*tileMap.tileheight)
				end
			end
		end
	end
	gfx.map = love.graphics.newImage(mapCanv:newImageData())
	gfx.map:setFilter('nearest', 'nearest')
	gfx.airMask = love.graphics.newImage(airCanv:newImageData())
	gfx.airMask:setFilter('nearest', 'nearest')
	gfx.sunLightMap = love.graphics.newImage(sunCanv:newImageData())
	gfx.sunLightMap:setFilter('nearest', 'nearest')
	setShaderDefaults(shaders.mapLighting, {
		['airMask'] = gfx.airMask,
		['viewScale'] = {gsx/worldSize.x, gsy/worldSize.y},
		['mapSize'] = {worldSize.x, worldSize.y}
	})
	setShaderDefaults(shaders.addSun, {
		['airMask'] = gfx.airMask,
		['sunLightMap'] = gfx.sunLightMap
	})
	sendShaderDefaults()
	love.graphics.setCanvas()
	mapCanv = nil
	airCanv = nil
	physEdgeTiles = {}
	for x=0, tileMap.width-1 do
		for y=0, tileMap.height-1 do
			if physTiles[x .. ',' .. y] then
				local enclosed = true
				for ox=-1, 1 do
					for oy=-1, 1 do
						if not physTiles[x+ox..','..y+oy] then
							enclosed = false
						end
					end
				end
				if not enclosed then
					physEdgeTiles[x .. ',' .. y] = true
				end
			end
		end
	end
	physHorizTiles = {}
	physHorizTables = {}
	local moreIDs = {}
	for k, _ in pairs(physEdgeTiles) do
		local coords = {}
		for c in string.gmatch(k, '([^,]+)') do
			table.insert(coords, tonumber(c))
		end
		local x, y = coords[1], coords[2]
		if not physEdgeTiles[x-1 .. ',' .. y] and physEdgeTiles[x+1 .. ',' .. y] then
			physHorizTiles[x .. ',' .. y] = true
			table.insert(physHorizTables, {{x=x, y=y}})
			table.insert(moreIDs, #physHorizTables)
		end
	end
	local more = true
	while more do
		more = false
		for i, v in pairs(moreIDs) do
			local tv = physHorizTables[i]
			tv = tv[#tv]
			physHorizTiles[tv.x+1 .. ',' .. tv.y] = true
			table.insert(physHorizTables[i], {x=tv.x+1, y=tv.y})
			if physEdgeTiles[tv.x+1 .. ',' .. tv.y] then
				more = true
			else
				moreIDs[i] = nil
			end
		end
	end

	function addPhysTile(x, y, w, h)
		local t = {
			body = love.physics.newBody(clientWorld, x, y, 'static'),
			shape = love.physics.newRectangleShape(w, h)
		}
		t.fixture = love.physics.newFixture(t.body, t.shape, 1)
		t.fixture:setUserData{type='tile'}
		table.insert(objects.client.tiles, t)
		if server.udp then
			local t = {
				body = love.physics.newBody(serverWorld, x, y, 'static'),
				shape = love.physics.newRectangleShape(w, h)
			}
			t.fixture = love.physics.newFixture(t.body, t.shape, 1)
			t.fixture:setUserData{type='tile'}
			table.insert(objects.server.tiles, t)
		end
		lightWorld:newRectangle(x, y, w, h)
	end

	for _, v in pairs(physHorizTables) do
		local start = v[1].x
		local fin = v[#v].x
		addPhysTile((start + fin)/2*tileMap.tilewidth, v[1].y*tileMap.tileheight + tileMap.tileheight/2,
					(fin - start)*tileMap.tilewidth, tileMap.tileheight)
	end
	physVertTables = {}
	moreIDs = {}
	for k, _ in pairs(physEdgeTiles) do
		local coords = {}
		for c in string.gmatch(k, '([^,]+)') do
			table.insert(coords, tonumber(c))
		end
		local x, y = coords[1], coords[2]
		if not physHorizTiles[x .. ',' .. y] and (not physEdgeTiles[x .. ',' .. y-1] or physHorizTiles[x .. ',' .. y-1]) then
			table.insert(physVertTables, {{x=x, y=y}})
			table.insert(moreIDs, #physVertTables)
		end
	end
	local more = true
	while more do
		more = false
		for i, v in pairs(moreIDs) do
			local tv = physVertTables[i]
			tv = tv[#tv]
			table.insert(physVertTables[i], {x=tv.x, y=tv.y+1})
			if not physHorizTiles[tv.x .. ',' .. tv.y+1] and physEdgeTiles[tv.x .. ',' .. tv.y+1] then
				more = true
			else
				moreIDs[i] = nil
			end
		end
	end
	for _, v in pairs(physVertTables) do
		local start = v[1].y
		local fin = v[#v].y
		addPhysTile(v[1].x*tileMap.tilewidth + tileMap.tilewidth/2, (start + fin)/2*tileMap.tileheight,
					tileMap.tilewidth, (fin - start)*tileMap.tileheight)
	end

	lighting.bake()
end

chestState = 1
function world.update(dt)
	if server.udp then
		serverWorld:update(dt)
	end
	clientWorld:update(dt)
	local lastState = chestState
	if (player:getX()-1488)^2+(player:getY()-1120)^2 < 48^2 then
		chestState = math.min(chestState + dt*8, 10)
	else
		chestState = math.max(chestState - dt*8, 1)
	end
	if chestState == 10 and lastState ~= chestState then
		player.health = 4
		sfx['heal']:clone():play()
	end
end

function world.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(gfx.map, 0, 0)
	for i, v in pairs(bakedLights) do
		if i > 2 then
			love.graphics.draw(gfx.torch, v[1], v[2], 0, 1, 1, gfx.torch:getWidth()/2, gfx.torch:getHeight()/2)
		end
	end
	love.graphics.draw(gfx.objects.chestSheet, anim.objects.chest.quads[math.floor(chestState)], 1488, 1120, 0, 1, 1, 16, 32)
	--logger.drawColliders()
	logger.drawColliders(objects.server, {200, 0, 0})
	logger.drawColliders(objects.client, {0, 200, 0})
end
