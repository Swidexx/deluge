
ssx = love.graphics.getWidth()
ssy = love.graphics.getHeight()
gsx = 480
gsy = 270
time = 0

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
	},
	player = {
		walkSheet = love.graphics.newImage('gfx/player/walk.png')
	},
	hud = {
		health1 = love.graphics.newImage('gfx/hud/health/skin1/1.png'),
		health2 = love.graphics.newImage('gfx/hud/health/skin1/2.png'),
		health3 = love.graphics.newImage('gfx/hud/health/skin1/3.png'),
		health4 = love.graphics.newImage('gfx/hud/health/skin1/4.png'),
		health5 = love.graphics.newImage('gfx/hud/health/skin1/5.png')
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

anim = {
	player = {
		walk = {
			sheet = gfx.player.walkSheet,
			quads = {},
			ids = {3,4,5,6,7,8,9,10,11,12,13,14,15}
		}
	}
}

for i=1, 15 do
	local x = (i-1)%4*16
	local y = math.floor((i-1)/4)*27
	table.insert(anim.player.walk.quads, love.graphics.newQuad(x, y, 15, 26, 64, 108))
end

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

function beginContact(a, b, coll)
	local bullet = a:getBody():isBullet() and a or b:getBody():isBullet() and b or nil
	if bullet then
		bullet:destroy()
	end
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
		body = love.physics.newBody(physWorld, 260, 100, 'dynamic'),
		shape = love.physics.newRectangleShape(15, 26)
	},
	floor = {
		body = love.physics.newBody(physWorld, ssx/2, ssy+5, 'static'),
		shape = love.physics.newRectangleShape(ssx, 10)
	},
	tiles = {},
	enemies = {},
	bullets = {}
}
objects.player.fixture = love.physics.newFixture(objects.player.body, objects.player.shape, 1)
objects.floor.fixture = love.physics.newFixture(objects.floor.body, objects.floor.shape, 1)

objects.player.fixture:setCategory(2)
objects.player.fixture:setMask(2)

objects.player.body:setFixedRotation(true)

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
					-- bullets fall through if math.abs(ox) + math.abs(oy) < 2 required
					if x+ox > 0 and x+ox < tileMap.width and
					y+oy > 0 and y+oy < tileMap.height and not physTiles[x+ox..','..y+oy] then
						enclosed = false
					end
				end
			end
			if not enclosed then
				addPhysTile(x*tileMap.tilewidth, y*tileMap.tileheight, tileMap.tilewidth)
			end
		end
	end
end
gfx.map = love.graphics.newImage(mapCanv:newImageData())
mapCanv = nil
