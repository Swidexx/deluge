
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
	client.updateRate = 1/30
end

function client.update(dt)
	repeat
		local data, msg = client.udp:receive()
		if data then
			local cmd, cmdParams = data:match('^(%S*) (.*)$')
			if cmd == 'setLocalPlayer' then
				local id = cmdParams
				print('id: ' .. id)
				player.id = id
			elseif cmd == 'chatMsg' then
				local id, msg = cmdParams:match('^(%S*) (.*)')
				table.insert(client.chatLog, {id=id, msg=msg})
				chat.lastOpen = time
			elseif cmd == 'stateUpdate' then
				local stateUpdate = json.decode(cmdParams)
				for k, v in pairs(stateUpdate.players) do
					client.players[k] = client.players[k] or {}
					client.players[k].x = v.x
					client.players[k].y = v.y
				end
			elseif cmd == 'remove' then
				local remove = json.decode(cmdParams)
				for k, _ in pairs(remove.players) do
					client.players[k] = nil
				end
			end
		end
	until not data
	if time - client.lastUpdate > client.updateRate then
		client.lastUpdate = time
		if player.id then
			local dg = string.format('%s %f %f', 'setPlayer', player.getX(), player.getY())
			client.udp:send(dg)
		end
	end
end
