
client = {}

function client.connect(ip, port)
	logger.log('Connecting to server at ' .. ip .. ':' .. port)
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
	client.msgCount = 0
	client.msgCountTime = time
end

function client.update(dt)
	repeat
		local data, msg = client.udp:receive()
		if data then
			if time - client.msgCountTime > 1 then
				client.msgCountTime = client.msgCountTime + 1
				logger.logVal('msgs/second from server', client.msgCount)
				client.msgCount = 0
			end
			client.msgCount = client.msgCount + 1
			local cmd, cmdParams = data:match('^(%S*) (.*)$')
			if cmd == 'returnPlayerID' then
				local id = cmdParams
				logger.log('id: ' .. id)
				player.id = id
			elseif cmd == 'chatMsg' then
				local id, msg = cmdParams:match('^(%S*) (.*)')
				if msg == '/steam' then
					if music.steam:isPlaying() then
						music.steam:stop()
					else
						music.steam:play()
					end
				end
				table.insert(client.chatLog, {id=id, msg=msg})
				chat.lastOpen = time
			elseif cmd == 'damage' then
				local pkg
				if pcall(function() pkg = json.decode(cmdParams) end) then
					player.damage(pkg.val)
					local x, y = (pkg.direction.x < 0 and -1 or 1)/math.sqrt(5), -2/math.sqrt(5)
					local scale = 100
					x, y = x*scale, y*scale
					objects.player.body:applyLinearImpulse(x, y)
				end
			elseif cmd == 'stateUpdate' then
				local stateUpdate
				if pcall(function() stateUpdate = json.decode(cmdParams) end) then
					stateUpdate.time = time
					table.insert(client.states, stateUpdate)
				end
			elseif cmd == 'add' then
				local add
				if pcall(function() add = json.decode(cmdParams) end) then
					if add.players then
						for k, v in pairs(add.players) do
							local new = not client.currentState.players[k]
							client.currentState.players[k] = {}
							setPlayerVals(client.currentState.players[k], v)
							if new then
								objects.otherPlayers[k] = {
									body = love.physics.newBody(physWorld, v.x, v.y, 'dynamic'),
									shape = love.physics.newRectangleShape(19, 33)
								}
								local opk = objects.otherPlayers[k]
								opk.fixture = love.physics.newFixture(opk.body, opk.shape, 1)
								opk.fixture:setUserData{type='otherPlayer', id=k}
								opk.fixture:setFriction(0)
								opk.fixture:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
								opk.body:setFixedRotation(true)
								opk.body:setGravityScale(0)
							end
						end
					end
					if add.bullets then
						for _, v in pairs(add.bullets) do
							if v.from ~= player.id then
								bullets.spawn(false, v.x, v.y, v.a, v.s)
							end
						end
					end
				end
			elseif cmd == 'remove' then
				local remove
				if pcall(function() remove = json.decode(cmdParams) end) then
					if remove.players then
						for k, _ in pairs(remove.players) do
							client.currentState.players[k] = nil
							if objects.otherPlayers[k] then
								objects.otherPlayers[k].fixture:destroy()
								objects.otherPlayers[k].body:destroy()
								objects.otherPlayers[k] = nil
							end
						end
					end
				end
			end
		end
	until not data
	if client.states[#client.states] and client.states[#client.states-1] then
		local timeOffset = time - client.states[#client.states-1].time
		client.stateTime = client.stateTime + dt
		client.stateTime = math.min(math.max(client.stateTime, client.states[#client.states-1].time), client.states[#client.states].time)
		logger.logVal('smoothing delay', time - client.stateTime)
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
					p.anim = {
						state = v.anim.state,
						frame = v.anim.frame
					}
					p.grapple = {
						on = v.grapple.on, x = v.grapple.x, y = v.grapple.y
					}
					p.holdingStaff = v.holdingStaff
				end
				if objects.otherPlayers[k] then
					objects.otherPlayers[k].body:setX(p.x)
					objects.otherPlayers[k].body:setY(p.y)
				end
			end
		end
	end
	if time - client.lastUpdate > client.updateRate then
		client.lastUpdate = time
		if player.id then
			local pClient = {
				x = player.getX(), y = player.getY(), direction = player.direction,
				anim = {
					state = player.anim.state,
					frame = player.anim.frame
				},
				grapple = {
					on = player.grapple.found, x = player.grapple.x, y = player.grapple.y
				},
				holdingStaff = player.inventory.selected == 2
			}
			local dg = string.format('%s %s', 'setPlayer', json.encode(pClient))
			client.udp:send(dg)
		end
	end
end

function client.drawPlayers()
	for k, v in pairs(client.currentState.players) do
		if k ~= player.id then
			love.graphics.setColor(255, 255, 255)
			if v.anim.state == 'walk' then
				if v.holdingStaff then
					local quad = anim.player.walkStaff.quads[v.anim.frame]
					love.graphics.draw(gfx.player.walkStaffSheet, quad, v.x, v.y,
										0, v.direction, 1, 11, 16)
				else
					local quad = anim.player.walk.quads[v.anim.frame]
					local _, _, w, h = quad:getViewport()
					love.graphics.draw(gfx.player.walkSheet, quad, v.x, v.y,
										0, v.direction, 1, math.floor(w/2), math.floor(h/2))
				end
			elseif v.anim.state == 'jump' then
				local quad = anim.player.jump.quads[v.anim.frame]
				local _, _, w, h = quad:getViewport()
				love.graphics.draw(gfx.player.jumpSheet, quad, v.x, v.y,
									0, v.direction, 1, math.floor(w/2), math.floor(h/2))
			elseif v.anim.state == 'attack' then
				if v.holdingStaff then
					local quad = anim.player.attackStaff.quads[v.anim.frame]
					love.graphics.draw(gfx.player.attackStaffSheet, quad, v.x, v.y,
										0, v.direction, 1, 15, 14)
				else
					local quad = anim.player.walk.quads[1]
					local _, _, w, h = quad:getViewport()
					love.graphics.draw(gfx.player.walkSheet, quad, v.x, v.y,
										0, v.direction, 1, math.floor(w/2), math.floor(h/2))
				end
			end
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
