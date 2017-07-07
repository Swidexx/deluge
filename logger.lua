
logger = {
	logs = {},
	logVals = {},
	logsEnabled = false,
	collidersEnabled = false,
	console = {active=false, val='', lastVal=''}
}

function logger.log(msg)
	if logger.logsEnabled then
		table.insert(logger.logs, msg)
	end
end

function logger.logVal(k, v)
	logger.logVals[k] = {v=v, time=time}
end

function logger.console.textinput(t)
	if t ~= '`' then
		logger.console.val = logger.console.val .. t
	end
end

function logger.console.keypressed(k, scancode, isrepeat)
	if k == 'return' then
		logger.console.submit()
	elseif k == 'backspace' then
		local lcv = logger.console.val
		logger.console.val = lcv:sub(0, math.max(lcv:len()-1, 0))
	elseif k == 'up' then
		logger.console.val = logger.console.lastVal
	elseif k == 'down' then
		logger.console.val = ''
	elseif k == 'escape' then
		logger.console.val = ''
		logger.console.active = false
	end
end

function logger.console.submit()
	logger.console.active = false
	logger.console.lastVal = logger.console.val
	if logger.console.val == 'logs' then
		logger.logsEnabled = not logger.logsEnabled
	elseif logger.console.val == 'colliders' then
		logger.collidersEnabled = not logger.collidersEnabled
	end
	logger.console.val = ''
end

function logger.drawColliders(e, color)
	color = color or {0, 0, 200}
	if logger.collidersEnabled then
		e = e or objects
		if e.shape then
			love.graphics.setLineWidth(1)
			if e.shape:getType() == 'polygon' then
				local points = {e.body:getWorldPoints(e.shape:getPoints())}
				love.graphics.setColor(color[1], color[2], color[3], 50)
				love.graphics.polygon('fill', points)
				love.graphics.setColor(0, 0, 0, 100)
				love.graphics.polygon('line', points)
			elseif e.shape:getType() == 'circle' then
				love.graphics.setColor(color[1], color[2], color[3], 50)
				love.graphics.circle('fill', e.body:getX(), e.body:getY(), e.shape:getRadius())
				love.graphics.setColor(0, 0, 0, 100)
				love.graphics.circle('line', e.body:getX(), e.body:getY(), e.shape:getRadius())
			else
				logger.log('unknown shape type')
			end
		else
			for i, v in pairs(e) do
				if type(v) == 'table' then
					logger.drawColliders(v, color)
				end
			end
		end
	end
end

function logger.draw()
	if logger.logsEnabled then
		love.graphics.setFont(fonts.f10)
		love.graphics.setShader(shaders.fontAlias)
		love.graphics.setColor(0, 96, 96)
		local pos = 1
		for i=math.max(#logger.logs-7, 1), #logger.logs do
			local v = logger.logs[i]
			love.graphics.print(v, 40, pos*12)
			pos = pos + 1
		end
		love.graphics.setColor(96, 96, 0)
		pos = 1
		for k, v in pairs(logger.logVals) do
			if time - v.time < 6 then
				love.graphics.print(k .. ': ' .. v.v, 40, pos*12 + 100)
				pos = pos + 1
			else
				logger.logVals[k] = nil
			end
		end
		love.graphics.setShader()
	end
	if logger.console.active then
		love.graphics.setColor(0, 0, 0, 200)
		love.graphics.rectangle('fill', 0, 0, 100, 14)
		love.graphics.setFont(fonts.f10)
		love.graphics.setShader(shaders.fontAlias)
		love.graphics.setColor(255, 255, 255)
		love.graphics.print(logger.console.val, 2, 1)
		love.graphics.setShader()
	end
end
