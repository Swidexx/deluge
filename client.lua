
client = {}

function client.connect(ip, port)
	debug.log('Connecting to server at ' .. ip .. ':' .. port)
	client.udp = socket.udp()
	client.udp:settimeout(0)
	client.udp:setpeername(ip, port)
	local dg = string.format('%s %s', 'requestPlayer', menu.nameInput.val)
	client.udp:send(dg)
	client.chatLog = {}
	client.states = {}
	client.stateIdx = 1
	client.stateTime = time
	client.currentState = {players={}}
	client.lastUpdate = 0
	client.updateRate = 1/20
end

function client.update(dt)
	repeat
		local data, msg = client.udp:receive()
		if data then
			local cmd, cmdParams = data:match('^(%S*) (.*)$')
			if cmd == 'returnPlayerID' then
				local id = cmdParams
				debug.log('id: ' .. id)
				player.id = id
			elseif cmd == 'chatMsg' then
				local id, msg = cmdParams:match('^(%S*) (.*)')
				table.insert(client.chatLog, {id=id, msg=msg})
				chat.lastOpen = time
			elseif cmd == 'stateUpdate' then
				local stateUpdate = json.decode(cmdParams)
				stateUpdate.time = time
				table.insert(client.states, stateUpdate)
			elseif cmd == 'add' then
				local add = json.decode(cmdParams)
				for k, v in pairs(add.players) do
					client.currentState.players[k] = {
						x=v.x, y=v.y, direction=v.direction,
						grapple={
							on=v.grapple.on, x=v.grapple.x, y=v.grapple.y
						}
					}
				end
			elseif cmd == 'remove' then
				local remove = json.decode(cmdParams)
				for k, _ in pairs(remove.players) do
					client.currentState.players[k] = nil
				end
			end
		end
	until not data
	if client.states[#client.states] and client.states[#client.states-1] then
		local timeOffset = time - client.states[#client.states-1].time
		--client.stateTime = client.stateTime + negGoldSoftplus(1 + timeOffset*2)*dt
		client.stateTime = client.stateTime + dt
		client.stateTime = math.min(math.max(client.stateTime, client.states[#client.states-1].time), client.states[#client.states].time)
		debug.log(time - client.stateTime)
		while client.states[client.stateIdx+1] and client.states[client.stateIdx+2]
		and client.states[client.stateIdx+1].time < client.stateTime do
			client.stateIdx = client.stateIdx + 1
		end
		local t = (client.stateTime - client.states[client.stateIdx].time)
			/ (client.states[client.stateIdx+1].time - client.states[client.stateIdx].time)
		for k, v in pairs(client.states[client.stateIdx].players) do
			local v2 = client.states[client.stateIdx+1].players[k]
			if v2 then
				local p = client.currentState.players[k]
				if p then
					p.x = lerp(v.x, v2.x, t)
					p.y = lerp(v.y, v2.y, t)
					p.direction = v.direction
					p.grapple = {
						on=v.grapple.on, x=v.grapple.x, y=v.grapple.y
					}
				end
			end
		end
	end
	if time - client.lastUpdate > client.updateRate then
		client.lastUpdate = time
		if player.id then
			local dg = string.format('%s %f %f %f %f %f %f', 'setPlayer', player.getX(), player.getY(), player.direction,
				player.grapple.found and 1 or 0, player.grapple.x, player.grapple.y)
			client.udp:send(dg)
		end
	end
end

function client.drawPlayers()
	for k, v in pairs(client.currentState.players) do
		if k ~= player.id then
			love.graphics.setColor(255, 255, 255)
			local quad = anim.player.walk.quads[1]
			local _, _, w, h = quad:getViewport()
			love.graphics.draw(gfx.player.walkSheet, quad, v.x, v.y,
								0, v.direction, 1, math.floor(w/2), math.floor(h/2))
			if v.grapple.on then
				love.graphics.setLineWidth(1)
				love.graphics.setColor(255, 0, 0)
				local a = math.atan2(v.grapple.x - v.x, v.y - v.grapple.y) - math.pi/2
				love.graphics.line(v.x, v.y, v.x + math.cos(a)*150, v.y + math.sin(a)*150)
				love.graphics.setColor(0, 0, 0)
				love.graphics.circle('line', v.grapple.x, v.grapple.y, 3)
			end
			love.graphics.setShader(shaders.fontAlias)
			love.graphics.setColor(0, 0, 0)
			love.graphics.setFont(fonts.f12)
			love.graphics.print(k, v.x-math.floor(fonts.f12:getWidth(k)/2), v.y-35)
			love.graphics.setShader()
		end
	end
end
