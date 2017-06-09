
server = {}

function server.start(port)
	print('Starting server on port ' .. port)
	server.udp = socket.udp()
	server.udp:settimeout(0)
	server.udp:setsockname('*', port)
	server.chatLog = {}
	server.players = {}
	server.ip2id = {}
	server.lastUpdate = 0
	server.updateRate = 1/30
end

function buildID(name, postfix)
	return name .. (postfix ~= 0 and '(' .. postfix .. ')' or '')
end

function server.addPlayer(id, ip, port)
	server.players[id] = {
		connection={ip=ip, port=port}, x=1260, y=1000, lastUpdate=time
	}
	server.ip2id[ip .. ':' .. port] = id
	local dg = string.format('%s %s', 'setLocalPlayer', id)
	server.udp:sendto(dg, ip, port)
end

function server.removePlayer(id)
	local v = server.players[id]
	server.ip2id[v.connection.ip .. ':' .. v.connection.port] = nil
	server.players[id] = nil
	server.removed = server.removed or {}
	server.removed.players = server.removed.players or {}
	server.removed.players[id] = true
	local dg = string.format('%s %s %s', 'chatMsg', 'Server', id .. ' disconnected')
	for k, v in pairs(server.players) do
		server.udp:sendto(dg, v.connection.ip, v.connection.port)
	end
	print('removed')
end

function server.update(dt)
	repeat
		local data, msg_or_ip, port_or_nil = server.udp:receivefrom()
		local id = server.ip2id[msg_or_ip .. ':' .. tostring(port_or_nil)]
		if id then
			server.players[id].lastUpdate = time
		end
		if data then
			local cmd, cmdParams = data:match('^(%S*) (.*)')
			if cmd == 'requestPlayer' then
				id = cmdParams:match('^(%S*)')
				local postfix = 0
				while server.players[buildID(id, postfix)] or buildID(id, postfix) == 'Server' do
					postfix = postfix + 1
				end
				local fullID = buildID(id, postfix)
				server.addPlayer(fullID, msg_or_ip, port_or_nil)
				local dg = string.format('%s %s %s', 'chatMsg', 'Server', fullID .. ' connected')
				for k, v in pairs(server.players) do
					server.udp:sendto(dg, v.connection.ip, v.connection.port)
				end
			elseif id then
				if cmd == 'chatMsg' then
					local dg = string.format('%s %s %s', 'chatMsg', id, cmdParams)
					for k, v in pairs(server.players) do
						server.udp:sendto(dg, v.connection.ip, v.connection.port)
					end
				elseif cmd == 'setPlayer' then
					local x, y = cmdParams:match('^(%-?[%d.e]*) (%-?[%d.e]*)$')
					x, y = tonumber(x), tonumber(y)
					local pv = server.players[id]
					pv.x = x
					pv.y = y
				elseif cmd == 'removePlayer' then
					server.removePlayer(id)
				end
			end
		elseif msg_or_ip ~= 'timeout' then
			print('Network error: ' .. tostring(msg_or_ip))
		end
	until not data
	for k, v in pairs(server.players) do
		if time - v.lastUpdate > 5 then
			server.removePlayer(k)
		end
	end
	if time - server.lastUpdate > server.updateRate then
		server.lastUpdate = time
		local stateUpdate = {players={}}
		for k, v in pairs(server.players) do
			stateUpdate.players[k] = {x=v.x, y=v.y}
		end
		local dgStateUpdate = string.format('%s %s', 'stateUpdate', json.encode(stateUpdate))
		local dgRemove
		if server.removed then
			dgRemove = string.format('%s %s', 'remove', json.encode(server.removed))
			server.removed = nil
		end
		for k, v in pairs(server.players) do
			local success, error = server.udp:sendto(dgStateUpdate, v.connection.ip, v.connection.port)
			if not success then
				print('State update failed: ' .. error)
			end
			if dgRemove then
				local success, error = server.udp:sendto(dgRemove, v.connection.ip, v.connection.port)
				if not success then
					print('Remove update failed: ' .. error)
				end
			end
		end
	end
end
