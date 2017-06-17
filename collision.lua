
function beginContact(a, b, coll)
	
end

function endContact(a, b, coll)

end

function preSolve(a, b, coll)

end

function postSolve(a, b, coll, normalImpulse, tangentImpulse)

end

love.physics.setMeter(24)
physWorld = love.physics.newWorld(0, 800, true)
physWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)
objects = {
	player = {
		body = love.physics.newBody(physWorld, 1260, 1000, 'dynamic'),
		shape = love.physics.newRectangleShape(19, 33)
	},
	playerSensorDown = {
		body = love.physics.newBody(physWorld, 1260, 1017, 'dynamic'),
		shape = love.physics.newRectangleShape(15, 1)
	},
	worldEdges = {
		left = {
			body = love.physics.newBody(physWorld, -5, worldSize.y/2, 'static'),
			shape = love.physics.newRectangleShape(10, worldSize.y)
		},
		right = {
			body = love.physics.newBody(physWorld, worldSize.x + 5, worldSize.y/2, 'static'),
			shape = love.physics.newRectangleShape(10, worldSize.y)
		},
		up = {
			body = love.physics.newBody(physWorld, worldSize.x/2, -5, 'static'),
			shape = love.physics.newRectangleShape(worldSize.x, 10)
		},
		down = {
			body = love.physics.newBody(physWorld, worldSize.x/2, worldSize.y + 5, 'static'),
			shape = love.physics.newRectangleShape(worldSize.x, 10)
		}
	},
	tiles = {},
	enemies = {},
	bullets = {}
}

objects.player.fixture = love.physics.newFixture(objects.player.body, objects.player.shape, 1)
objects.player.fixture:setUserData{type='player'}
objects.player.fixture:setFriction(0)
objects.player.fixture:setCategory(2)
objects.player.fixture:setMask(2)
objects.player.body:setFixedRotation(true)

objects.playerSensorDown.fixture = love.physics.newFixture(objects.playerSensorDown.body, objects.playerSensorDown.shape, 1)
objects.playerSensorDown.fixture:setUserData{type='playerSensorDown'}
objects.playerSensorDown.fixture:setSensor(true)

objects.player.sensorDownJoint = love.physics.newWeldJoint(objects.player.body, objects.playerSensorDown.body, 1260, 1000)

for _, v in pairs(objects.worldEdges) do
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
		body = love.physics.newBody(physWorld, x, y, 'static'),
		shape = love.physics.newRectangleShape(w, h)
	}
	t.fixture = love.physics.newFixture(t.body, t.shape, 1)
	t.fixture:setUserData{type='tile'}
	table.insert(objects.tiles, t)
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
