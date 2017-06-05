
client = {}

function client.connect(ip, port)
	print('Connecting to server at ' .. ip .. ':' .. port)
	client.udp = socket.udp()
	client.udp:settimeout(0)
	client.udp:setpeername(ip, port)
	local dg = string.format('%s %s', 'requestPlayer', menu.nameInput.val)
	client.udp:send(dg)
	client.chatLog = {}
	client.players = {}
	client.lastUpdate = 0
	client.updateRate = 1/20
end

function client.update(dt)
	repeat
		local data, msg = client.udp:receive()
		if data then
			local cmd, cmdParams = data:match('^(%S*) (.*)$')
			if cmd == 'setLocalPlayer' then
				local id = cmdParams:match('^(%S*)')
				player.id = id
			elseif cmd == 'chatMsg' then
				local id, msg = cmdParams:match('^(%S*) (.*)')
				table.insert(client.chatLog, {id=id, msg=msg})
				chat.lastOpen = time
			elseif cmd == 'setPlayer' then
				local id, entParams = cmdParams:match('^(%S*) (.*)')
				local x, y = entParams:match('^(%-?[%d.e]*) (%-?[%d.e]*)$')
				x, y = tonumber(x), tonumber(y)
				client.players[id] = client.players[id] or {}
				local pv = client.players[id]
				pv.x = x
				pv.y = y
			end
		end
	until not data
	if time - client.lastUpdate > client.updateRate then
		client.lastUpdate = time
		if player.id then
			local dg = string.format('%s %s %f %f', 'setPlayer', player.id, player.getX(), player.getY())
			client.udp:send(dg)
		end
	end
end
