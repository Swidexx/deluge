
ssx = love.graphics.getWidth()
ssy = love.graphics.getHeight()
gsx = 480
gsy = 270
time = 0

gfx = {
	techemonic = love.graphics.newImage('gfx/techemonic.png'),
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
		walkSheet = love.graphics.newImage('gfx/player/walk.png'),
		jumpSheet = love.graphics.newImage('gfx/player/jump.png')
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
			quads = {}
		},
		jump = {
			sheet = gfx.player.jumpSheet,
			quads = {}
		}
	}
}
for i=1, 16 do
	local x = (i-1)*20
	local y = 0
	table.insert(anim.player.walk.quads, love.graphics.newQuad(x, y, 19, 33,
					gfx.player.walkSheet:getWidth(), gfx.player.walkSheet:getHeight()))
end
for i=1, 8 do
	local x = (i-1)*20
	local y = 0
	table.insert(anim.player.jump.quads, love.graphics.newQuad(x, y, 19, 34,
					gfx.player.jumpSheet:getWidth(), gfx.player.jumpSheet:getHeight()))
end

sfx = {
	music = {
		rhymull = love.audio.newSource('sfx/Rhymull.ogg', 'stream')
	},
	death = love.audio.newSource('sfx/Death.wav', 'static'),
	explosion = love.audio.newSource('sfx/Explosion.wav', 'static'),
	hitHurt = love.audio.newSource('sfx/Hit_Hurt.wav', 'static'),
	jump = love.audio.newSource('sfx/Jump.wav', 'static'),
	land = love.audio.newSource('sfx/Land.wav', 'static'),
	powerUp = love.audio.newSource('sfx/PowerUp.wav', 'static'),
	step = love.audio.newSource('sfx/Step.wav', 'static'),
	techemonic = love.audio.newSource('sfx/techemonic.wav', 'static')
}

sfx.music.rhymull:setLooping(true)

shaders = {
	splashScreen = love.graphics.newShader('shaders/splashScreen.glsl'),
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
