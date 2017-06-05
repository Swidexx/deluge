
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
	server.lastUpdate = 0
	server.updateRate = 1/20
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
				server.players[fullID] = {connection={ip=msg_or_ip, port=port_or_nil}, x=1260, y=1000}
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
			elseif cmd == 'setPlayer' then
				local id, entParams = cmdParams:match('^(%S*) (.*)')
				local x, y = entParams:match('^(%-?[%d.e]*) (%-?[%d.e]*)$')
				x, y = tonumber(x), tonumber(y)
				local pv = server.players[id]
				pv.x = x
				pv.y = y
			elseif cmd == 'removePlayer' then

			end
		elseif msg_or_ip ~= 'timeout' then
			print('Network error: ' .. tostring(msg_or_ip))
		end
	until not data
	if time - server.lastUpdate > server.updateRate then
		server.lastUpdate = time
		for k, v in pairs(server.players) do
			for k2, v2 in pairs(server.players) do
				local dg = string.format('%s %s %f %f', 'setPlayer', k2, v2.x, v2.y)
				server.udp:sendto(dg, v.connection.ip, v.connection.port)
			end
		end
	end
end
