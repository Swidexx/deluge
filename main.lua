
require 'loadassets'

LightWorld = require 'light_world'
lightWorld = LightWorld{
	ambient = {0, 0, 0},
	shadowBlur = 0
}
lightWorld.shadow_buffer:setFilter('nearest', 'nearest')
playerLight = lightWorld:newLight(0, 0, 255, 255, 255, 200)

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
	love.window.setTitle("Deluge (" .. love.timer.getFPS() .. " FPS)")
	time = time + dt
	local mx, my = screen2game(love.mouse.getPosition())
	if gamestate == 'playing' then
		bullets.update(dt)
		world.update(dt)
		enemies.update(dt)
		player.update(dt)
		playerLight:setPosition(player.getX(), player.getY())
		hud.update(dt)
	end
	camera.x = math.floor(player.getX() - gsx/2 + 0.5) +
				math.floor((mx-gsx/2)/3) + (mx-gsx/2 < 0 and 1 or 0)
	camera.y = math.floor(player.getY() - gsy/2 + 0.5) +
				math.floor((my-gsy/2)/3) + (my-gsy/2 < 0 and 1 or 0)
	camera.x = math.min(math.max(camera.x, 0), worldSize.x - gsx)
	camera.y = math.min(math.max(camera.y, 0), worldSize.y - gsy)

	lightWorld:setTranslation(-camera.x, -camera.y, 1)
	lightWorld:update(dt)
	shaders.mapLighting:send('camPos', {camera.x, camera.y})

	collectgarbage()
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
		lightWorld:draw(function()
			love.graphics.setCanvas(canvases.lightWorld)
			love.graphics.setColor(255, 255, 255)
			love.graphics.rectangle('fill', 0, 0, worldSize.x, worldSize.y)
		end)
		camera:unset()
		love.graphics.setColor(255, 255, 255)
		love.graphics.setCanvas(canvases.lightMap)
		--love.graphics.setShader(shaders.max)
		--shaders.max:send('other', love.graphics.newImage(lightWorld.shadow_buffer:newImageData()))
		--love.graphics.draw(gfx.sunLightMap, -camera.x, -camera.y)
		love.graphics.draw(lightWorld.shadow_buffer, 0, 0)
		love.graphics.setShader()
		love.graphics.setCanvas(canvases.lightMapBlur_l8)
		love.graphics.draw(canvases.lightMap, 0, 0, 0, 1/8, 1/8)
		love.graphics.setShader(shaders.blur)
		shaders.blur:send('radius', 1)
		shaders.blur:send('dir', {1, 0})
		love.graphics.draw(love.graphics.newImage(canvases.lightMapBlur_l8:newImageData()), 0, 0)
		shaders.blur:send('dir', {0, 1})
		love.graphics.draw(love.graphics.newImage(canvases.lightMapBlur_l8:newImageData()), 0, 0)
		love.graphics.setShader()
		love.graphics.setCanvas(canvases.lightMapBlur)
		love.graphics.draw(canvases.lightMapBlur_l8, 0, 0, 0, 8, 8)
		shaders.mapLighting:send('lightMap', love.graphics.newImage(canvases.lightMap:newImageData()))
		shaders.mapLighting:send('lightMapBlur', love.graphics.newImage(canvases.lightMapBlur:newImageData()))
		love.graphics.setCanvas(canvases.game)
		love.graphics.setShader(shaders.mapLighting)
		love.graphics.draw(love.graphics.newImage(canvases.game:newImageData()), 0, 0)
		love.graphics.setShader()
		love.graphics.setColor(255, 255, 255, 200)
		love.graphics.draw(gfx.sunLightMap, -camera.x, -camera.y)
		hud.draw()
	end
	love.graphics.setCanvas()
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(canvases.game, ssx/2-gameScale*gsx/2, ssy/2-gameScale*gsy/2, 0, gameScale, gameScale)
end
