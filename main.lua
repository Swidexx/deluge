
tileMap = require 'map/DelugeConcept2-newtiles'
worldSize = {x=tileMap.width*tileMap.tilewidth, y=tileMap.height*tileMap.tileheight}

json = require 'json'
require 'socket'
require 'utils'
require 'logger'
require 'loadassets'
require 'server'
require 'client'
require 'chat'
require 'lighting'
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

function love.load()
	gamestate = 'splash'
	sfx['techemonic']:play()
	sfx['techemonic']:seek(3)
	sfx['techemonic']:setPitch(0.6)
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
	serverTime = serverTime + dt
	if server.udp then
		server.update(dt)
	end
	if client.udp then
		client.update(dt)
	end
	local mx, my = screen2game(love.mouse.getPosition())
	if gamestate == 'playing' then
		world.update(dt)
		bullets.update(dt)
		player.update(dt)
		playerLight:setPosition(player.getX(), player.getY())
		hud.update(dt)
	end
	--[[
	camera.x = math.floor(player.getX() - gsx/2 + 0.5) +
				math.floor((mx-gsx/2)/3) + (mx-gsx/2 < 0 and 1 or 0)
	camera.y = math.floor(player.getY() - gsy/2 + 0.5) +
				math.floor((my-gsy/2)/3) + (my-gsy/2 < 0 and 1 or 0)
	]]
	camera.x = math.floor(player.getX() - gsx/2 + 0.5)
	camera.y = math.floor(player.getY() - gsy/2 + 0.5)
	camera.x = math.min(math.max(camera.x, 0), worldSize.x - gsx)
	camera.y = math.min(math.max(camera.y, 0), worldSize.y - gsy)

	lighting.update(dt)

	logger.logVal('#objects.client.bullets', #objects.client.bullets)

	if music['steam']:isPlaying() then
		music['steam']:setPitch(love.math.noise(time)+0.25)
	end

	collectgarbage()
end

function love.mousepressed(x, y, btn, isTouch)
	if gamestate == 'splash' then
		sfx['techemonic']:stop()
		music['strategy']:play()
		gamestate = 'menu'
	elseif gamestate == 'menu' then
		menu.mousepressed(x, y, btn)
	elseif gamestate == 'playing' then
		player.mousepressed(x, y, btn)
		lighting.mousepressed(x, y, btn)
	end
end

function love.mousereleased(x, y, btn, isTouch)
	if gamestate == 'menu' then
		menu.mousereleased(x, y, btn)
	end
end

function love.wheelmoved(x, y)
	if gamestate == 'playing' then
		player.wheelmoved(x, y)
	end
end

function love.textinput(t)
	if logger.console.active then
		logger.console.textinput(t)
	else
		if gamestate == 'menu' then
			menu.textinput(t)
		elseif gamestate == 'playing' then
			chat.textinput(t)
		end
	end
end

function love.keypressed(k, scancode, isrepeat)
	if devmode and k == '`' then
		logger.console.active = not logger.console.active
	end
	if logger.console.active then
		logger.console.keypressed(k, scancode, isrepeat)
	else
		if gamestate == 'splash' then
			sfx['techemonic']:stop()
			music['strategy']:play()
			gamestate = 'menu'
		elseif gamestate == 'menu' then
			menu.keypressed(k, scancode, isrepeat)
		elseif gamestate == 'playing' then
			if not chat.typing then
				player.keypressed(k, scancode, isrepeat)
				lighting.keypressed(k, scancode, isrepeat)
				if k == 'escape' then
					gamestate = 'menu'
					music['rhymull']:stop()
					music['strategy']:play()
				end
			end
			chat.keypressed(k, scancode, isrepeat)
		end
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
			music['strategy']:play()
		end
	elseif gamestate == 'menu' then
		menu.draw()
	elseif gamestate == 'playing' then
		love.graphics.setShader()
		love.graphics.setColor(170, 200, 255)
		love.graphics.rectangle('fill', -1, -1, gsx+2, gsy+2)
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(gfx.enviro.background, 0, 0)
		camera:set()
		world.draw()
		client.drawEnemies()
		client.drawPlayers()
		player.draw()
		bullets.draw()
		lightWorld:draw(function()
			love.graphics.setShader()
			love.graphics.setCanvas(canvases.lightWorldTemp)
			love.graphics.setColor(255, 255, 255)
			love.graphics.rectangle('fill', 0, 0, worldSize.x, worldSize.y)
		end)
		camera:unset()
		lighting.draw()
		hud.draw()
		chat.draw()
	end
	logger.draw()
	love.graphics.setCanvas()
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(canvases.game, ssx/2-gameScale*gsx/2, ssy/2-gameScale*gsy/2, 0, gameScale, gameScale)
end

function love.quit()
	if client.udp then
		client.udp:send('removePlayer $')
	end
	if server.udp then
		dg = string.format('%s %s %s', 'chatMsg', 'Server', 'closed')
		for k, v in pairs(objects.server.players) do
			server.udp:sendto(dg, v.connection.ip, v.connection.port)
		end
	end
end
