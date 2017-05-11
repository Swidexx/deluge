require 'loadassets'
require 'collision'
require 'camera'
require 'easing'
require 'pg'
require 'menu'
require 'world'
require 'enemies'
require 'hud'
require 'player'
require 'bullets'

love.filesystem.setIdentity(love.window.getTitle())
math.randomseed(love.timer.getTime())

function love.load()
	gamestate = 'splash'
	hud.set()
	sfx.techemonic:play()
	sfx.techemonic:seek(3)
	sfx.techemonic:setPitch(0.6)
end

gameScale = math.max(math.min(ssx/gsx, ssy/gsy), 1)
function love.resize(w, h)
	ssx = w
	ssy = h
	gameScale = math.max(math.min(ssx/gsx, ssy/gsy), 1)
end

function screen2game(x, y)
	x = x - (ssx-gameScale*gsx)/2
	x = x / gameScale
	y = y - (ssy-gameScale*gsy)/2
	y = y / gameScale
	return math.floor(x), math.floor(y)
end

function love.update(dt)
	time = time + dt
	local mx, my = screen2game(love.mouse.getPosition())
	if gamestate == 'playing' then
		bullets.update(dt)
		world.update(dt)
		enemies.update(dt)
		player.update(dt)
		hud.update(dt)
	end
	camera.x = math.floor(player.getX() - gsx/2 + 0.5) +
				math.floor((mx-gsx/2)/3) + (mx-gsx/2 < 0 and 1 or 0)
	camera.y = math.floor(player.getY() - gsy/2 + 0.5) +
				math.floor((my-gsy/2)/3) + (my-gsy/2 < 0 and 1 or 0)
	camera.x = math.min(math.max(camera.x, 0), worldSize.x - gsx)
	camera.y = math.min(math.max(camera.y, 0), worldSize.y - gsy)
end

function love.mousepressed(x, y, btn, isTouch)
	if gamestate == 'splash' then
		sfx.techemonic:stop()
		music.home:play()
		gamestate = 'menu'
	elseif gamestate == 'menu' then
		menu.mousepressed(x, y, btn)
	elseif gamestate == 'playing' then
		player.mousepressed(x, y, btn)
	end
end

function love.mousereleased(x, y, btn, isTouch)
	if gamestate == 'menu' then
		menu.mousereleased(x, y, btn)
	end
end

function love.keypressed(k, scancode, isrepeat)
	if gamestate == 'playing' then
		player.keypressed(k, scancode, isrepeat)
		if k == 'escape' then
			gamestate = 'menu'
			music.rhymull:stop()
			music.home:play()
		end
	elseif gamestate == 'menu' then
		menu.keypressed(k)
	end
end

function love.draw()
	love.graphics.setCanvas(canvases.game)
	if gamestate == 'splash' then
		love.graphics.setShader(shaders.splashScreen)
		shaders.splashScreen:send('time', time)
		love.graphics.draw(gfx.techemonic, 0, 0)
		love.graphics.setShader()
		if time > 5 then
			gamestate = 'menu'
			music.home:play()
		end
	elseif gamestate == 'menu' then
		menu.draw()
	elseif gamestate == 'playing' then
		love.graphics.setColor(170, 200, 255)
		love.graphics.rectangle('fill', -1, -1, gsx+2, gsy+2)
		camera:set()
		world.draw()
		enemies.draw()
		player.draw()
		bullets.draw()
		camera:unset()
		hud.draw()
	end
	love.graphics.setCanvas()
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(canvases.game, ssx/2-gameScale*gsx/2, ssy/2-gameScale*gsy/2, 0, gameScale, gameScale)
end
