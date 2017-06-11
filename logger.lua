
logger = {
	logs = {},
	logVals = {},
	logsEnabled = false
}

function logger.log(msg)
	if logger.logsEnabled then
		table.insert(logger.logs, msg)
	end
end

function logger.logVal(k, v)
	logger.logVals[k] = {v=v, time=time}
end

function logger.draw()
	if logger.logsEnabled then
		love.graphics.setFont(fonts.f10)
		love.graphics.setShader(shaders.fontAlias)
		love.graphics.setColor(0, 0, 0)
		local pos = 1
		for i=math.max(#logger.logs-7, 1), #logger.logs do
			local v = logger.logs[i]
			love.graphics.print(v, gsx/2, pos*12)
			pos = pos + 1
		end
		love.graphics.setColor(0, 64, 0)
		pos = 1
		for k, v in pairs(logger.logVals) do
			if time - v.time < 6 then
				love.graphics.print(k .. ': ' .. v.v, gsx/2, pos*12 + 100)
				pos = pos + 1
			else
				logger.logVals[k] = nil
			end
		end
		love.graphics.setShader()
	end
end
