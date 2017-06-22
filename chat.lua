
chat = {
	typing = false,
	message = '',
	lastMessage = '',
	lastOpen = -6
}

function chat.textinput(k)
	if chat.typing then
		chat.message = chat.message .. k
	end
end

function chat.keypressed(k, scancode, isrepeat)
	if k == 'escape' then
		chat.typing = false
		chat.message = ''
	elseif k == 'return' then
		chat.typing = not chat.typing
		chat.lastOpen = time
		if chat.message:sub(0, 4) == '/tp ' then
			local id = chat.message:sub(5, chat.message:len())
			for k, v in pairs(client.currentState.players) do
				if k == id then
					objects.player.body:setPosition(v.x, v.y)
					break
				end
			end
		end
		if not chat.typing and chat.message:gsub('%s+', '') ~= '' then
			local idx = 0
			while true do
				local txt = chat.message:sub(idx, math.min(idx - player.id:len() + 21))
				idx = idx - player.id:len() + 22
				local dg = string.format('%s %s', 'chatMsg', txt)
				client.udp:send(dg)
				if idx > chat.message:len() then
					break
				end
			end
			chat.lastMessage = chat.message
		end
		chat.message = ''
	elseif k == '/' then
		if not chat.typing then
			chat.typing = true
		end
	elseif k == 'up' then
		if chat.typing then
			chat.message = chat.lastMessage
		end
	elseif k == 'down' then
		chat.message = ''
	elseif k == 'v' then
		if chat.typing and (love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl')) then
			local paste = love.system.getClipboardText()
			for v in paste:gmatch('.') do
				if v ~= '\n' then
					chat.message = chat.message .. v
				end
			end
		end
	elseif k == 'backspace' then
		if chat.typing then
			chat.message = chat.message:sub(0, math.max(chat.message:len()-1, 0))
		end
	end
end

function chat.draw()
	if chat.typing or time - chat.lastOpen < 6 then
		love.graphics.setColor(0, 0, 0, math.min(6-(time-chat.lastOpen), 1)*96)
		love.graphics.rectangle('fill', 0, 152, 150, 100)
	end
	love.graphics.setShader(shaders.fontAlias)
	love.graphics.setFont(fonts.f10)
	if chat.typing or time - chat.lastOpen < 6 then
		local pos = 1
		for i=math.max(#client.chatLog-7, 1), #client.chatLog do
			local v = client.chatLog[i]
			love.graphics.setColor(0, 128, 192, math.min(6-(time-chat.lastOpen), 1)*255)
			if v.id == 'Server' then
				love.graphics.setColor(0, 192, 128, math.min(6-(time-chat.lastOpen), 1)*255)
			end
			love.graphics.print(v.id .. ': ' .. v.msg, 2, 140 + pos*12)
			pos = pos + 1
		end
	end
	if chat.typing then
		chat.lastOpen = time
		love.graphics.setColor(0, 0, 0, 128)
		love.graphics.rectangle('fill', 2, gsy-16, 146, 12)
		love.graphics.setColor(0, 128, 192)
		local txt = chat.message:sub(math.max(chat.message:len()-22, 0), chat.message:len())
		love.graphics.print(txt .. (time%1 > 0.5 and '|' or ''), 3, gsy-16)
	end
	love.graphics.setShader()
end
