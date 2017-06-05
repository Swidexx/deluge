
chat = {
	typing = false,
	message = '',
	lastOpen = -6
}

function chat.textinput(k)
	if chat.typing then
		if chat.message:len() < 22 then
			chat.message = chat.message .. k
		end
	end
end

function chat.keypressed(k, scancode, isrepeat)
	if k == 'escape' then
		chat.typing = false
		chat.message = ''
	elseif k == 'return' then
		chat.typing = not chat.typing
		chat.lastOpen = time
		if not chat.typing and chat.message ~= '' then
			local dg = string.format('%s %s %s', 'chatMsg', player.id, chat.message)
			client.udp:send(dg)
			chat.message = ''
		end
	elseif k == 'v' then
		if chat.typing and (love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl')) then
			local paste = love.system.getClipboardText()
			for v in paste:gmatch('.') do
				if chat.message:len() < 22 then
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
	love.graphics.setShader(shaders.fontAlias)
	love.graphics.setFont(fonts.f10)
	if chat.typing or time - chat.lastOpen < 6 then
		love.graphics.setColor(0, 128, 192, math.min(6-(time-chat.lastOpen), 1)*255)
		local pos = 1
		for i=math.max(#client.chatLog-7, 1), #client.chatLog do
			local v = client.chatLog[i]
			love.graphics.print(v.id .. ': ' .. v.msg, 2, 140 + pos*12)
			pos = pos + 1
		end
	end
	if chat.typing then
		love.graphics.setColor(0, 0, 0, 128)
		love.graphics.rectangle('fill', 2, gsy-16, 120, 12)
		love.graphics.setColor(0, 128, 192)
		love.graphics.print(chat.message .. (time%1 > 0.5 and '|' or ''), 3, gsy-16)
	end
	love.graphics.setShader()
end
