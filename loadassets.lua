
ssx = love.graphics.getWidth()
ssy = love.graphics.getHeight()
gsx = 480
gsy = 270

gfx = {
	menu = {
		bg = love.graphics.newImage('gfx/menu/bg.png'),
		title = love.graphics.newImage('gfx/menu/title.png'),
		play = love.graphics.newImage('gfx/menu/play.png'),
		options = love.graphics.newImage('gfx/menu/options.png'),
		exit = love.graphics.newImage('gfx/menu/exit.png'),
		volume = love.graphics.newImage('gfx/menu/volume.png'),
		sfx = love.graphics.newImage('gfx/menu/sfx.png'),
		music = love.graphics.newImage('gfx/menu/music.png'),
		fullscreen = love.graphics.newImage('gfx/menu/fullscreen.png'),
		windowsize = love.graphics.newImage('gfx/menu/windowsize.png'),
		back = love.graphics.newImage('gfx/menu/back.png'),
	},
	enemies = {
		dummy = love.graphics.newImage('gfx/dummy2.png')
	}
}

function recSetFilter(e)
    if type(e) == "table" then
        for _, v in pairs(e) do
            recSetFilter(v)
        end
    else
        e:setFilter('nearest', 'nearest')
    end
end
recSetFilter(gfx)
love.graphics.setDefaultFilter('nearest', 'nearest')
love.graphics.setLineStyle('rough')

--love.mouse.setCursor(love.mouse.newCursor(love.image.newImageData('gfx/cursors/defpix2.png'), 0, 0))

shaders = {
	menubg = love.graphics.newShader('shaders/menubg.glsl'),
	fontAlias = love.graphics.newShader('shaders/fontAlias.glsl')
}

fonts = {
	f8 = love.graphics.newFont(8),
	f18 = love.graphics.newFont(18),
	f24 = love.graphics.newFont(24)
}
for _, v in pairs(fonts) do
	v:setFilter('nearest', 'nearest', 0)
end

canvases = {
	game = love.graphics.newCanvas(gsx, gsy)
}
for _, v in pairs(canvases) do
	v:setFilter('nearest', 'nearest')
end

local taserCanv = love.graphics.newCanvas(6, 4)
love.graphics.setCanvas(taserCanv)
love.graphics.setColor(0, 0, 0)
love.graphics.rectangle('fill', 0, 0, 6, 4)
love.graphics.setColor(255, 255, 0)
love.graphics.setLineWidth(1)
love.graphics.line(1, 2, 5, 2)
gfx.taser = love.graphics.newImage(taserCanv:newImageData())
taserCanv = nil

love.physics.setMeter(24)
physWorld = love.physics.newWorld(0, 800, true)
physWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)
objects = {
	player = {
		body = love.physics.newBody(physWorld, 100, 100, 'dynamic'),
		shape = love.physics.newRectangleShape(16, 24)
	},
	floor = {
		body = love.physics.newBody(physWorld, ssx/2, ssy+5, 'static'),
		shape = love.physics.newRectangleShape(ssx, 10)
	},
	tiles = {}
}
objects.player.fixture = love.physics.newFixture(objects.player.body, objects.player.shape, 1)
objects.floor.fixture = love.physics.newFixture(objects.floor.body, objects.floor.shape, 1)

objects.player.body:setFixedRotation(true)

function beginContact(a, b, coll)
	local bullet = a:getBody():isBullet() and a or b:getBody():isBullet() and b or nil
	if bullet then
		bullet:getBody():destroy()
		bullet:destroy()
	end
end

function endContact(a, b, coll)

end

function preSolve(a, b, coll)

end

function postSolve(a, b, coll, normalImpulse, tangentImpulse)

end

function spawnBullet(x, y, a, s)
	bullets[#bullets+1] = {}
	local v = bullets[#bullets]
	v.timer = 3
	v.body = love.physics.newBody(world, x, y, 'dynamic')
	v.shape = love.physics.newRectangleShape(4, 8)
	v.fixture = love.physics.newFixture(v.body, v.shape, 50)
	v.body:setBullet(true)
	v.body:setAngle(a)
	v.body:setLinearVelocity(math.cos(a - math.pi/2)*s, math.sin(a - math.pi/2)*s)
end

function addPhysTile(x, y, s)
	local t = {
		body = love.physics.newBody(physWorld, x+s/2, y+s/2, 'static'),
		shape = love.physics.newCircleShape(s/2-0.4)
	}
	t.fixture = love.physics.newFixture(t.body, t.shape, 1)
	table.insert(objects.tiles, t)
end

tileMap = require 'map/DelugeConcept2'
local mapCanv = love.graphics.newCanvas(tileMap.width*tileMap.tilewidth, tileMap.height*tileMap.tileheight)
love.graphics.setCanvas(mapCanv)
local tileImage = love.graphics.newImage('map/Plainstileset.png')
gfx.tileImage = tileImage
local quads = {}
local tileset = tileMap.tilesets[1]
for y=0, tileset.imageheight-1, tileset.tileheight do
	for x=0, tileset.imagewidth-1, tileset.tilewidth do
		table.insert(quads, love.graphics.newQuad(x, y, tileset.tilewidth, tileset.tileheight, tileset.imagewidth, tileset.imageheight))
	end
end
physTiles = {}
love.graphics.setColor(255, 255, 255)
for _, layer in ipairs(tileMap.layers) do
	for y=0, tileMap.height-1 do
		for x=0, tileMap.width-1 do
			local idx = y*tileMap.width + x + 1
			if layer.data[idx] ~= 0 then
				if layer.name == "Terrain" then
					physTiles[x..','..y] = true
				end
				love.graphics.draw(tileImage, quads[layer.data[idx]], x*tileMap.tilewidth, y*tileMap.tileheight)
			end
		end
	end
end
love.graphics.setColor(0, 0, 255, 200)
for x=0, tileMap.width-1 do
	for y=0, tileMap.height-1 do
		if physTiles[x..','..y] then
			local enclosed = true
			for ox=-1, 1 do
				for oy=-1, 1 do
					if math.abs(ox) + math.abs(oy) < 2 and x+ox > 0 and x+ox < tileMap.width and
					y+oy > 0 and y+oy < tileMap.height and not physTiles[x+ox..','..y+oy] then
						enclosed = false
					end
				end
			end
			if not enclosed then
				--love.graphics.rectangle('fill', x*tileMap.tilewidth+2, y*tileMap.tileheight+2, tileMap.tilewidth/2, tileMap.tileheight/2)
				addPhysTile(x*tileMap.tilewidth, y*tileMap.tileheight, tileMap.tilewidth)
			end
		end
	end
end
gfx.map = love.graphics.newImage(mapCanv:newImageData())
mapCanv = nil
