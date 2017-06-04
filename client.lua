
client = {}

function client.connect(ip, port)
	print('Connecting to server at ' .. ip .. ':' .. port)
	client.udp = socket.udp()
	client.udp:settimeout(0)
	client.udp:setpeername(ip, port)
	local dg = string.format('%s %s', 'requestPlayer', menu.nameInput.val)
	client.udp:send(dg)
	client.chatLog = {}
end

function client.receive()
	repeat
		local data, msg = client.udp:receive()
		if data then
			local cmd, cmdParams = data:match('^(%S*) (.*)$')
			if cmd == 'setLocalPlayer' then
				local id = cmdParams:match('^(%S*)')
				playerID = id
			elseif cmd == 'chatMsg' then
				local id, msg = cmdParams:match('^(%S*) (.*)')
				table.insert(client.chatLog, {id=id, msg=msg})
			end
		end
	until not data
end
