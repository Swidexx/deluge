
server = {}

function server.start(port)
	logger.log('Starting server on port ' .. port)
	server.udp = socket.udp()
	server.udp:settimeout(0)
	server.udp:setsockname('*', port)
	server.ip2id = {}
	server.chatLog = {}
	server.lastUpdate = 0
	server.updateRate = 1/20
	server.added = {}
	server.removed = {}

	addEnemy{x=1345, y=1000, name='Dummy', type='dummy'}
end

function server.addPlayer(id, ip, port)
	objects.server.players[id] = {
		connection = {ip = ip, port = port},
		lastUpdate = time
	}
	setPlayerVals(objects.server.players[id], {
		x = 1260, y = 1000, direction = 1,
		anim = {
			state = 'jump',
			frame = 8
		},
		grapple = {
			on = false, x = 0, y = 0
		},
		holdingStaff = false
	})
	local v = objects.server.players[id]
	if not objects.server.players[id] then
		objects.server.players[id] = {
			body = love.physics.newBody(serverWorld, v.x, v.y, 'dynamic');
			shape = love.physics.newRectangleShape(19, 33)
		}
		local opk = objects.server.players[id]
		opk.fixture = love.physics.newFixture(opk.body, opk.shape, 1)
		opk.fixture:setUserData{type='serverPlayer', id=k}
		opk.fixture:setFriction(0)
		opk.fixture:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
		opk.body:setFixedRotation(true)
		opk.body:setGravityScale(0)
	end
	server.ip2id[ip .. ':' .. port] = id
	server.added.players = server.added.players or {}
	server.added.players[id] = {}
	setPlayerVals(server.added.players[id], objects.server.players[id])
	local dg = string.format('%s %s', 'returnPlayerID', id)
	server.udp:sendto(dg, ip, port)
	dg = string.format('%s %s %s', 'chatMsg', 'Server', id .. ' connected')
	for k, v in pairs(objects.server.players) do
		server.udp:sendto(dg, v.connection.ip, v.connection.port)
	end
end

function server.removePlayer(id)
	local v = objects.server.players[id]
	server.ip2id[v.connection.ip .. ':' .. v.connection.port] = nil
	local opk = objects.server.players[id]
	if opk then
		if opk.fixture then
			opk.fixture:destroy()
			opk.body:destroy()
		end
		objects.server.players[id] = nil
	end
	server.removed.players = server.removed.players or {}
	server.removed.players[id] = true
	local dg = string.format('%s %s %s', 'chatMsg', 'Server', id .. ' disconnected')
	for k, v in pairs(objects.server.players) do
		server.udp:sendto(dg, v.connection.ip, v.connection.port)
	end
end

function server.removeEnemy(id)
	local v = objects.server.enemies[id]
	local opk = objects.server.enemies[id]
	if opk then
		opk.main.fixture:destroy()
		opk.main.body:destroy()
		opk.sensorDown.fixture:destroy()
		opk.sensorDown.body:destroy()
		objects.server.enemies[id] = nil
	end
	server.removed.enemies = server.removed.enemies or {}
	server.removed.enemies[id] = true
end

function server.update(dt)
	repeat
		local data, msg_or_ip, port_or_nil = server.udp:receivefrom()
		local id = server.ip2id[msg_or_ip .. ':' .. tostring(port_or_nil)]
		if id then
			objects.server.players[id].lastUpdate = time
		end
		if data then
			local cmd, cmdParams = data:match('^(%S*) (.*)')
			if cmd == 'requestPlayer' then
				local reqID = cmdParams
				logger.log('server - requestPlayer: ' .. reqID)
				local postfix = 0
				while objects.server.players[buildID(reqID, postfix)] or buildID(reqID, postfix) == 'Server' do
					postfix = postfix + 1
				end
				local fullID = buildID(reqID, postfix)
				server.addPlayer(fullID, msg_or_ip, port_or_nil)
				-- send current state to new player
				local add = {players={}, enemies={}}
				for k, v in pairs(objects.server.players) do
					add.players[k] = {}
					setPlayerVals(add.players[k], v)
				end
				for k, v in pairs(objects.server.enemies) do
					add.enemies[k] = {}
					setEnemyVals(add.enemies[k], v)
				end
				local dg = string.format('%s %s', 'add', json.encode(add))
				server.udp:sendto(dg, msg_or_ip, port_or_nil)
			elseif id then
				if cmd == 'chatMsg' then
					local dg = string.format('%s %s %s', 'chatMsg', id, cmdParams)
					for k, v in pairs(objects.server.players) do
						server.udp:sendto(dg, v.connection.ip, v.connection.port)
					end
				elseif cmd == 'setPlayer' then
					local pClient
					if pcall(function() pClient = json.decode(cmdParams) end) then
						local pServer = objects.server.players[id]
						if pServer then
							setPlayerVals(pServer, pClient)
						end
						local opk = objects.server.players[k]
						if opk then
							opk.body:setX(pClient.x)
							opk.body:setY(pClient.y)
							opk.body:setAngle(pClient.r)
						end
					end
				elseif cmd == 'removePlayer' then
					server.removePlayer(id)
				elseif cmd == 'addBullet' then
					local bullet
					if pcall(function() bullet = json.decode(cmdParams) end) then
						server.added.bullets = server.added.bullets or {}
						bullet.from = id
						table.insert(server.added.bullets, bullet)
					end
				elseif cmd == 'damage' then
					local damage
					if pcall(function() damage = json.decode(cmdParams) end) then
						if damage.type == 'player' then
							local dg = string.format('%s %s', 'damage', cmdParams)
							local p = objects.server.players[damage.id]
							if p then
								server.udp:sendto(dg, p.connection.ip, p.connection.port)
							end
						elseif damage.type == 'enemy' then
							--[[
							local enemy = objects.server.enemies[damage.id]
							if enemy then
								enemies.damage(enemy, damage.val)
								local x, y = (damage.direction.x < 0 and -1 or 1)/math.sqrt(5), -2/math.sqrt(5)
								local scale = 100
								enemy.main.body:applyLinearImpulse(x*scale, y*scale)
							end
							]]
							local enemy = objects.server.enemies[damage.id]
							if enemy then
								enemies.damage(enemy, damage)
							end
						end
					end
				end
			end
		elseif msg_or_ip ~= 'timeout' then
			logger.log('Network error: ' .. tostring(msg_or_ip))
		end
	until not data
	for k, v in pairs(objects.server.players) do
		if time - v.lastUpdate > 5 then
			server.removePlayer(k)
		end
	end
	if time - server.lastUpdate > server.updateRate then
		server.lastUpdate = time
		local stateUpdate = {players={}, enemies={}, time=time}
		for k, v in pairs(objects.server.players) do
			stateUpdate.players[k] = {}
			setPlayerVals(stateUpdate.players[k], v)
		end
		for k, v in pairs(objects.server.enemies) do
			stateUpdate.enemies[k] = {}
			setEnemyVals(stateUpdate.enemies[k], v)
		end
		local dgStateUpdate = string.format('%s %s', 'stateUpdate', json.encode(stateUpdate))
		local dgAdd = string.format('%s %s', 'add', json.encode(server.added))
		server.added = {}
		local dgRemove = string.format('%s %s', 'remove', json.encode(server.removed))
		server.removed = {}
		for k, v in pairs(objects.server.players) do
			server.udp:sendto(dgStateUpdate, v.connection.ip, v.connection.port)
			server.udp:sendto(dgAdd, v.connection.ip, v.connection.port)
			server.udp:sendto(dgRemove, v.connection.ip, v.connection.port)
		end
	end

	enemies.update(dt)
end
