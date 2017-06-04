
server = {}

function server.start(port)
	print('Starting server on port ' .. port)
	hosting = true
	server.udp = socket.udp()
	server.udp:settimeout(0)
	server.udp:setsockname('*', port)
	server.chatLog = {}
	server.entIdCountDict = {}
	server.players = {}
end

function buildID(name, postfix)
	return name .. (postfix and '(' .. postfix .. ')' or '')
end

function server.update(dt)
	repeat
		local data, msg_or_ip, port_or_nil = server.udp:receivefrom()
		if data then
			local cmd, cmdParams = data:match('^(%S*) (.*)')
			if cmd == 'requestPlayer' then
				local id = cmdParams:match('^(%S*)')
				local postfix = nil
				local idcnt = server.entIdCountDict[id] or 0
				if server.players[id] then
					postfix = idcnt + 1
					server.entIdCountDict[id] = idcnt + 1
				end
				local fullID = buildID(id, postfix)
				server.players[fullID] = {connection={ip=msg_or_ip, port=port_or_nil}}
				local dg = string.format('%s %s', 'setLocalPlayer', fullID)
				server.udp:sendto(dg, msg_or_ip, port_or_nil)
				dg = string.format('%s %s %s', 'chatMsg', 'Server', fullID .. ' connected')
				for k, v in pairs(server.players) do
					server.udp:sendto(dg, v.connection.ip, v.connection.port)
				end
			elseif cmd == 'chatMsg' then
				local id, msg = cmdParams:match('^(%S*) (.*)')
				local dg = string.format('%s %s %s', 'chatMsg', id, msg)
				for k, v in pairs(server.players) do
					server.udp:sendto(dg, v.connection.ip, v.connection.port)
				end
			elseif cmd == 'removePlayer' then

			end
		elseif msg_or_ip ~= 'timeout' then
			error('Network error: ' .. tostring(msg_or_ip))
		end
	until not data
end
