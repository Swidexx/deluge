
lighting = {}

LightWorld = require 'light_world'
lightWorld = LightWorld{
	ambient = {0, 0, 0},
	shadowBlur = 2
}
lightWorld.shadow_buffer:setFilter('nearest', 'nearest')
playerLight = lightWorld:newLight(0, 0, 255, 255, 255, 00)
placeholderLight = lightWorld:newLight(0, 0, 255, 255, 255, 0)
--caveLight = lightWorld:newLight(1000, 1200, 240, 190, 60, 300)
lightWorld:refreshScreenSize(gsx, gsy)

lights = {}
placingLights = false

bakedLights = {
	{1160, 1058, 255, 255, 255, 300},
	{823, 854, 255, 255, 255, 300},
	{556, 966, 240, 190, 60, 300},
	{487, 1173, 240, 190, 60, 300},
	{806, 1222, 240, 190, 60, 300},
	{996, 1190, 240, 190, 60, 300},
	{991, 1354, 240, 190, 60, 300},
	{1388, 1428, 240, 190, 60, 300},
	{1214, 1514, 240, 190, 60, 300},
	{586, 1476, 240, 190, 60, 300},
	{321, 1545, 240, 190, 60, 300},
	{566, 1355, 240, 190, 60, 300},
	{256, 1330, 240, 190, 60, 300},
	{134, 1451, 240, 190, 60, 300}
}

function lighting.bake()
	lightWorld:refreshScreenSize(worldSize.x, worldSize.y)
	lightWorld:setTranslation(0, 0, 1)
	local tempLights = {}
	for _, v in pairs(bakedLights) do
		table.insert(tempLights, lightWorld:newLight(unpack(v)))
	end
	lightWorld:draw(function()
		love.graphics.setCanvas(canvases.bakedLightMap)
		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle('fill', 0, 0, worldSize.x, worldSize.y)
	end)
	love.graphics.setCanvas(canvases.bakedLightMap)
	love.graphics.setColor(255, 255, 255)
	love.graphics.setShader(shaders.addSun)
	love.graphics.draw(lightWorld.shadow_buffer, 0, 0)
	love.graphics.setShader(shaders.blur)
	shaders.blur:send('steps', 64)
	shaders.blur:send('dir', {0, 1})
	local tempCanv = love.graphics.newCanvas(canvases.bakedLightMapBlur:getWidth(), canvases.bakedLightMapBlur:getHeight())
	love.graphics.setCanvas(tempCanv)
	love.graphics.draw(canvases.bakedLightMap, 0, 0)
	shaders.blur:send('dir', {1, 0})
	love.graphics.setCanvas(canvases.bakedLightMapBlur)
	love.graphics.draw(tempCanv, 0, 0)
	shaderDefaults[shaders.mapLighting] = shaderDefaults[shaders.mapLighting] or {}
	local defaults = shaderDefaults[shaders.mapLighting]
	defaults['bakedLightMap'] = love.graphics.newImage(canvases.bakedLightMap:newImageData())
	defaults['bakedLightMapBlur'] = love.graphics.newImage(canvases.bakedLightMapBlur:newImageData())
	sendShaderDefaults()
	for _, v in pairs(tempLights) do
		lightWorld:remove(v)
	end
	lightWorld:refreshScreenSize(gsx, gsy)
end

function lighting.update(dt)
	lightWorld:setTranslation(-camera.x, -camera.y, 1)
	lightWorld:update(dt)
	shaders.mapLighting:send('camPos', {camera.x, camera.y})

	if placingLights then
		local x, y = screen2game(love.mouse.getPosition())
		placeholderLight:setPosition(x + camera.x, y + camera.y)
	end
end

function lighting.mousepressed(x, y, btn)
	x, y = screen2game(x, y)
	if placingLights then
		if btn == 1 then
			local light = lightWorld:newLight(x + camera.x, y + camera.y, 255, 255, 255, 300)
			table.insert(lights, light)
		elseif btn == 2 then
			local light = lightWorld:newLight(x + camera.x, y + camera.y, 240, 190, 60, 300)
			table.insert(lights, light)
		end
	end
end

function lighting.keypressed(k, scancode, isrepeat)
	if devmode then
		if k == 'l' then
			placingLights = not placingLights
			if placingLights then
				placeholderLight:setRange(300)
			else
				placeholderLight:setRange(0)
			end
		elseif k == 'c' then
			if love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl') then
				local txt = ''
				for _, v in pairs(lights) do
					txt = txt .. '{' .. v.x .. ', ' .. v.y .. ', ' ..
						v.red .. ', ' .. v.green .. ', ' .. v.blue .. ', ' .. v.range .. '},\n'
				end
				love.system.setClipboardText(txt)
			end
		end
	end
end

function lighting.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setCanvas(canvases.lightWorldTemp)
	love.graphics.draw(canvases.game, 0, 0)
	love.graphics.setCanvas(canvases.game)
	love.graphics.setShader(shaders.mapLighting)
	shaders.mapLighting:send('lightMap', love.graphics.newImage(lightWorld.shadow_buffer:newImageData()))
	love.graphics.draw(canvases.lightWorldTemp, 0, 0)
	love.graphics.setShader()
end
