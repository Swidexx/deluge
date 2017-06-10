
function buildID(name, postfix)
	return name .. (postfix ~= 0 and '(' .. postfix .. ')' or '')
end

function logB(b, x)
	return math.log(x)/math.log(b)
end

function negGoldSoftplus(x)
	k = (1 + math.sqrt(5))/2
	return logB(k, 1 + math.pow(k, -x))
end

function lerp(a, b, t)
	return a + (b - a) * t
end

debug = {
	showColliders = false,
	logs = {},
	logsEnabled = false
}

function debug.log(msg)
	if debug.logsEnabled then
		table.insert(debug.logs, msg)
	end
end

function debug.drawColliders(e)
	e = e or objects
	if e.shape then
		love.graphics.setLineWidth(1)
		if e.shape:getType() == 'polygon' then
			local points = {e.body:getWorldPoints(e.shape:getPoints())}
			love.graphics.setColor(0, 0, 200, 50)
			love.graphics.polygon('fill', points)
			love.graphics.setColor(0, 0, 0, 100)
			love.graphics.polygon('line', points)
		elseif e.shape:getType() == 'circle' then
			love.graphics.setColor(0, 0, 200, 50)
			love.graphics.circle('fill', e.body:getX(), e.body:getY(), e.shape:getRadius())
			love.graphics.setColor(0, 0, 0, 100)
			love.graphics.circle('line', e.body:getX(), e.body:getY(), e.shape:getRadius())
		else
			debug.log('unknown shape type')
		end
	else
		for i, v in pairs(e) do
			if type(v) == 'table' then
				debug.drawColliders(v)
			end
		end
	end
end

function debug.draw()
	if debug.showColliders then
		camera:set()
		debug.drawColliders()
		camera:unset()
	end
	if debug.logsEnabled then
		love.graphics.setFont(fonts.f10)
		love.graphics.setShader(shaders.fontAlias)
		love.graphics.setColor(0, 0, 0, 128)
		local pos = 1
		for i=math.max(#debug.logs-7, 1), #debug.logs do
			local v = debug.logs[i]
			love.graphics.print(v, gsx - 200, pos*12)
			pos = pos + 1
		end
		love.graphics.setShader()
	end
end
