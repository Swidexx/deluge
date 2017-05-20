
lighting = {}

LightWorld = require 'light_world'
lightWorld = LightWorld{
	ambient = {0, 0, 0},
	shadowBlur = 2
}
lightWorld.shadow_buffer:setFilter('nearest', 'nearest')
playerLight = lightWorld:newLight(0, 0, 255, 255, 255, 00)
caveLight = lightWorld:newLight(1000, 1200, 240, 190, 60, 300)
caveLight2 = lightWorld:newLight(900, 1400, 240, 190, 60, 300)
lightWorld:refreshScreenSize(gsx, gsy)

function lighting.update(dt)
	lightWorld:setTranslation(-camera.x, -camera.y, 1)
	lightWorld:update(dt)
	shaders.mapLighting:send('camPos', {camera.x, camera.y})
	shaders.addSun:send('camPos', {camera.x, camera.y})
end

function lighting.draw()
	love.graphics.setColor(255, 255, 255)
	--[[
	love.graphics.setCanvas(canvases.lightMap)
	local offX = (camera.x/6-math.floor(camera.x/6))*6
	local offY = (camera.y/6-math.floor(camera.y/6))*6
	love.graphics.draw(lightWorld.shadow_buffer, -offX, -offY)
	love.graphics.setShader(shaders.addSun)
	love.graphics.draw(love.graphics.newImage(canvases.lightMap:newImageData()), 0, 0)
	love.graphics.setShader()
	love.graphics.setCanvas(canvases.lightMapBlur_l6)
	love.graphics.draw(canvases.lightMap, 0, 0, 1/6, 1/6)
	love.graphics.setShader(shaders.blur)
	shaders.blur:send('radius', 2)
	shaders.blur:send('dir', {1, 0})
	love.graphics.draw(love.graphics.newImage(canvases.lightMapBlur_l6:newImageData()), 0, 0)
	shaders.blur:send('dir', {0, 1})
	love.graphics.draw(love.graphics.newImage(canvases.lightMapBlur_l6:newImageData()), 0, 0)
	love.graphics.setShader()
	love.graphics.setCanvas(canvases.lightMapBlur)
	love.graphics.draw(canvases.lightMapBlur_l6, offX, offY, 0, 6, 6)
	]]
	love.graphics.setCanvas(canvases.lightMap)
	love.graphics.setShader(shaders.addSun)
	love.graphics.draw(lightWorld.shadow_buffer, 0, 0)
	love.graphics.setCanvas(canvases.lightMapBlur)
	love.graphics.setShader(shaders.blur)
	shaders.blur:send('steps', 32)
	shaders.blur:send('dir', {0, 1})
	love.graphics.draw(love.graphics.newImage(canvases.lightMap:newImageData()), 0, 0)
	shaders.blur:send('dir', {1, 0})
	--love.graphics.setColor(255, 255, 255, 128)
	love.graphics.draw(love.graphics.newImage(canvases.lightMapBlur:newImageData()), 0, 0)
	love.graphics.setColor(255, 255, 255)

	love.graphics.setCanvas(canvases.game)
	love.graphics.setShader(shaders.mapLighting)
	shaders.mapLighting:send('lightMap', love.graphics.newImage(canvases.lightMap:newImageData()))
	shaders.mapLighting:send('lightMapBlur', love.graphics.newImage(canvases.lightMapBlur:newImageData()))
	love.graphics.draw(love.graphics.newImage(canvases.game:newImageData()), 0, 0)
	love.graphics.setShader()
end
