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
	gamestate = 'menu'
	hud.set()
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
	mx, my = screen2game(love.mouse.getPosition())
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
	if gamestate == 'menu' then
		menu.mousepressed(x, y, btn)
	elseif gamestate == 'playing' then
		player.shoot(x, y)
	end
end

function love.keypressed(k, scancode, isrepeat)
	if gamestate == 'playing' then
		player.keypressed(k, scancode, isrepeat)
		if k == 'escape' then
			gamestate = 'menu'
		end
	elseif gamestate == 'menu' then
		menu.keypressed(k)
	end
end

gfx.rogue2 = love.graphics.newImage('gfx/rogue2.png')
gfx.rogue2:setFilter('nearest', 'nearest')
function love.draw()
	love.graphics.setCanvas(canvases.game)
	if gamestate == 'menu' then
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
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(gfx.rogue2, mx-gfx.rogue2:getWidth()/2, my-80)
	end
	love.graphics.setCanvas()
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(canvases.game, ssx/2-gameScale*gsx/2, ssy/2-gameScale*gsy/2, 0, gameScale, gameScale)
end
