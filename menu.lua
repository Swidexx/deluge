
menu = {
	state = 'main',
	btns = {},
	overlay = {time=0}
}

function setSFXVolume(n)
	for k, v in pairs(sfx) do
		local fac = soundVolumes.sfx[k] or 1
		v:setVolume(n*fac)
	end
end

function setMusicVolume(n)
	for k, v in pairs(music) do
		local fac = soundVolumes.music[k] or 1
		v:setVolume(n*fac)
	end
end

function menu.saveDefaults()
	local str = "vals={name='" .. menu.nameInput.val .. "',ip='" .. menu.ipInput.val .. "',volume={main=" ..
		menu.mainVolume.val .. ",sfx=" .. menu.sfxVolume.val .. ",music=" .. menu.musicVolume.val .. "}}\nreturn vals"
	love.filesystem.write('menuDefaults.lua', str)
end

function menu.overlay.open()
	menu.overlay.isOpen = true
	menu.overlay.time = time
end

function menu.overlay.close()
	menu.overlay.isOpen = false
	menu.overlay.time = time
end

function menu.addButton(t)
	local x, y, font
	if t.img then
		x = t.x and t.x - t.img:getWidth()/2 or gsx/2 - t.img:getWidth()/2
		y = t.y and t.y - t.img:getHeight()/2 or gsy/2 - t.img:getHeight()/2
	elseif t.text then
		font = t.font or love.graphics.newFont(16)
		x = t.x and t.x - font:getWidth(t.text)/2 or gsx/2 - font:getWidth(t.text)/2
		y = t.y and t.y - font:getHeight(t.text)/2 or gsy/2 - font:getHeight(t.text)/2
	else
		font = t.font or love.graphics.newFont(16)
		local twidth = (t.width and t.width or 0)
		x = t.x or gsx/2
		y = t.y or gsy/2 - font:getHeight()/2
	end
	x = math.floor(x)
	y = math.floor(y)

	local val = t.val
	if not val and (t.type == 'switch' or t.type == 'slider' or t.type == 'cycle') then
		val = 0
	end
	local width = t.width
	if not width and t.type == 'slider' and t.img then
		width = t.img:getWidth()+2
	end
	local numvals = t.numvals
	if not numvals and t.type == 'cycle' then
		numvals = 2
	end
	local state = t.state or 'main'
	if not menu.btns[state] then menu.btns[state] = {} end
	table.insert(menu.btns[state], {img=t.img, text=t.text, id=t.id, type=t.type, font=font, val=val, width=width, numvals=numvals, held=false, x=x, y=y})
	return menu.btns[state][#menu.btns[state]]
end
if not love.filesystem.exists('menuDefaults.lua') then
	local str = "vals={name='Player',ip='127.0.0.1:1357',volume={main=0.5,sfx=0.5,music=0.5}}\nreturn vals"
	love.filesystem.write('menuDefaults.lua', str)
end
menu.defaults = dofile(love.filesystem.getRealDirectory("menuDefaults.lua") .. "/menuDefaults.lua")

menu.addButton{img=gfx.menu.title, type='static', y=40}
menu.addButton{img=gfx.menu.play, id='play', y=140}
menu.addButton{img=gfx.menu.options, id='options', y=180}
menu.addButton{img=gfx.menu.exit, id='exit', y=230}
menu.nameInput = menu.addButton{state='play', id='name', type='textinput', val=menu.defaults.name, width=200, y=90}
menu.ipInput = menu.addButton{state='play', id='ipinput', type='textinput', val=menu.defaults.ip, width=200, y=120}
menu.addButton{state='play', text='HOST', id='host', y=170}
menu.addButton{state='play', text='CONNECT', id='connect', y=190}
menu.addButton{state='play', img=gfx.menu.back, id='back', y=230}
menu.mainVolume = menu.addButton{state='options', img=gfx.menu.volume, id='volume', type='slider', val=menu.defaults.volume.main, y=50}
love.audio.setVolume(menu.defaults.volume.main)
menu.sfxVolume = menu.addButton{state='options', img=gfx.menu.sfx, id='sfx', type='slider', val=menu.defaults.volume.sfx, width=56, x=gsx/2-30, y=70}
setSFXVolume(menu.defaults.volume.sfx)
menu.musicVolume = menu.addButton{state='options', img=gfx.menu.music, id='music', type='slider', val=menu.defaults.volume.music, width=56, x=gsx/2+30, y=70}
setMusicVolume(menu.defaults.volume.music)
menu.addButton{state='options', img=gfx.menu.fullscreen, id='fullscreen', type='switch', val=0, y=130}
menu.addButton{state='options', img=gfx.menu.windowsize, id='windowsize', type='cycle', val=1, numvals=4, y=150}
menu.addButton{state='options', img=gfx.menu.opensavedir, id='opensavedir', y=190}
menu.addButton{state='options', img=gfx.menu.back, id='back', y=230}

function menu.mousepressed(x, y, btn)
	local mx, my = screen2game(love.mouse.getPosition())
	if gamestate == 'menu' then
		menu.textInputSelected = nil
		for i, v in pairs(menu.btns[menu.state]) do
			if v.type == 'slider' then
				if mx > v.x+v.img:getWidth()/2-v.width/2 and mx < v.x+v.img:getWidth()/2+v.width/2 and my > v.y and my < v.y+v.img:getHeight() then
					menu.sliderHeld = v
					break
				end
			elseif v.type == 'textinput' then
				if mx > v.x-v.width/2 and mx < v.x+v.width/2 and my > v.y-2 and my < v.y+v.font:getHeight()+4 then
					menu.textInputSelected = v
				end
			else
				if v.img then
					if mx > v.x and mx < v.x+v.img:getWidth() and my > v.y and my < v.y+v.img:getHeight() then
						if v.id == 'play' then
							menu.state = 'play'
							sfx['select']:clone():play()
						elseif v.id == 'options' then
							menu.state = 'options'
							sfx['select']:clone():play()
						elseif v.id == 'exit' then
							love.event.quit()
							sfx['select']:clone():play()
						elseif v.id == 'back' then
							menu.state = 'main'
							menu.saveDefaults()
							sfx['select']:clone():play()
						elseif v.id == 'fullscreen' then
							love.window.setFullscreen(not love.window.getFullscreen())
							v.val = 1-v.val
							sfx['select']:clone():play()
						elseif v.id == 'windowsize' and not love.window.getFullscreen() then
							v.val = (v.val+1)%v.numvals
							_, _, flags = love.window.getMode()
							local w, h = gsx*(v.val+1), gsy*(v.val+1)
							love.window.setMode(w, h, flags)
							love.resize(w, h)
							sendShaderDefaults()
							sfx['select']:clone():play()
						elseif v.id == 'opensavedir' then
							love.system.openURL("file://" .. love.filesystem.getSaveDirectory())
							sfx['select']:clone():play()
						end
						break
					end
				elseif v.text then
					if mx > v.x and mx < v.x+v.font:getWidth(v.text) and my > v.y and my < v.y+v.font:getHeight(v.text) then
						if v.id == 'host' then
							gamestate = 'playing'
							local ip, port = menu.ipInput.val:match('(.-):(.*)')
							server.start(port or '1357')
							client.connect('127.0.0.1', port or '1357')
							world.generate()
							music['strategy']:stop()
							music['rhymull']:play()
							sfx['select']:clone():play()
						elseif v.id == 'connect' then
							gamestate = 'playing'
							local ip, port = menu.ipInput.val:match('(.-):(.*)')
							client.connect(ip, port or '1357')
							world.generate()
							music['strategy']:stop()
							music['rhymull']:play()
							sfx['select']:clone():play()
						end
					end
				end
			end
		end
	elseif menu.overlay.isOpen and time - menu.overlay.time > 1/6 then
		if mx > gsx/6 and mx < gsx/6 + gsx*2/3 and my > 0 and my < gsy*3/4 then
			menu.overlay.close()
		end
	end
end

function menu.mousereleased(x, y, btn)
	menu.sliderHeld = nil
end

ipKeys = '0123456789.:abcdef'
nameKeys = "`~1!2@3#4$5%6^7&8*9(0)-_=+qwertyuiopasdfghjklzxcvbnm[{]}|;:,<.>/?"

function menu.textinput(k)
	if menu.textInputSelected then
		local v = menu.textInputSelected
		if v.id == 'ipinput' and ipKeys:find(k:lower(), 1, true) and v.val:len() < 39 or
		v.id == 'name' and nameKeys:find(k:lower(), 1, true) and v.val:len() < 16 then
			v.val = v.val .. k
		end
	end
end

function menu.keypressed(k, scancode, isrepeat)
	local tis = menu.textInputSelected
	if k == 'escape' then
		if menu.state == 'main' then
			--love.event.quit()
		else
			menu.state = 'main'
			menu.saveDefaults()
			menu.sliderHeld = nil
			menu.textInputSelected = nil
		end
	elseif k == 'return' then
		menu.textInputSelected = nil
	elseif k == 'v' then
		if tis and (love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl')) then
			local paste = love.system.getClipboardText()
			for v in paste:gmatch('.') do
				if tis.id == 'ipinput' and ipKeys:find(v:lower(), 1, true) and tis.val:len() < 39 or
				tis.id == 'name' and nameKeys:find(v:lower(), 1, true) and tis.val:len() < 16 then
					tis.val = tis.val .. v
				end
			end
		end
	elseif k == 'backspace' then
		if tis then
			tis.val = tis.val:sub(0, math.max(tis.val:len()-1, 0))
		end
	end
end

function menu.draw()
	local mx, my = screen2game(love.mouse.getPosition())
	if gamestate == 'menu' then
		if menu.sliderHeld then
			local v = menu.sliderHeld
			if v.id == 'volume' then
				v.val = math.min(math.max((mx-(v.x+v.img:getWidth()/2-v.width/2))/(v.width-3), 0), 1)
				love.audio.setVolume(v.val)
			elseif v.id == 'sfx' then
				v.val = math.min(math.max((mx-(v.x+v.img:getWidth()/2-v.width/2))/(v.width-3), 0), 1)
				setSFXVolume(v.val)
			elseif v.id == 'music' then
				v.val = math.min(math.max((mx-(v.x+v.img:getWidth()/2-v.width/2))/(v.width-3), 0), 1)
				setMusicVolume(v.val)
			end
		end
		love.graphics.setShader(shaders.menubg)
		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle('fill', 0, 0, gsx, gsy)
		love.graphics.setShader()
		for i, v in pairs(menu.btns[menu.state]) do
			if ((v.type ~= 'static' and v.type ~= 'slider') and v.img and mx > v.x and mx < v.x+v.img:getWidth() or
			v.type == 'slider' and mx > v.x+v.img:getWidth()/2-v.width/2 and mx < v.x+v.img:getWidth()/2+v.width/2) and my > v.y and my < v.y+v.img:getHeight() then
				love.graphics.setColor(255, 255, 255, 200)
			else
				love.graphics.setColor(255, 255, 255)
			end
			if v.id == 'windowsize' and love.window.getFullscreen() then
				love.graphics.setColor(255, 255, 255, 100)
			end
			if v.img then
				love.graphics.draw(v.img, v.x, v.y)
			elseif v.text then
				love.graphics.setFont(v.font)
				love.graphics.setShader(shaders.fontAlias)
				if mx > v.x and mx < v.x+v.font:getWidth(v.text) and my > v.y and my < v.y+v.font:getHeight(v.text) then
					love.graphics.setColor(91, 78, 37, 200)
				else
					love.graphics.setColor(91, 78, 37)
				end
				love.graphics.print(v.text, v.x, v.y)
				love.graphics.setShader()
			end
			if v.type == 'switch' and v.val ~= 0 then
				love.graphics.setColor(0, 0, 0, 32)
				love.graphics.rectangle('fill', v.x, v.y, v.img:getWidth(), v.img:getHeight())
			elseif v.type == 'slider' then
				love.graphics.setColor(0, 0, 0, 64)
				love.graphics.setLineWidth(1)
				love.graphics.rectangle('line', math.floor(v.x+v.img:getWidth()/2-v.width/2), v.y-1, v.width, v.img:getHeight()+2)
				love.graphics.setColor(0, 0, 0, 32)
				love.graphics.rectangle('fill', math.floor(v.x+v.img:getWidth()/2-v.width/2+1), v.y, (v.width-3)*v.val, v.img:getHeight()-1)
			elseif v.type == 'cycle' then
				love.graphics.setColor(0, 0, 0, 32)
				love.graphics.rectangle('fill', v.x, v.y+4, v.img:getWidth()*(v.val+1)/v.numvals, v.img:getHeight()-8)
			elseif v.type == 'textinput' then
				love.graphics.setColor(0, 0, 0, 32)
				love.graphics.rectangle('fill', math.floor(v.x-v.width/2), v.y-2, v.width, v.font:getHeight()+4)
				if mx > v.x-v.width/2 and mx < v.x+v.width/2 and my > v.y-2 and my < v.y+v.font:getHeight()+4 then
					love.graphics.setColor(91, 78, 37, 200)
				else
					love.graphics.setColor(91, 78, 37)
				end
				love.graphics.setFont(v.font)
				love.graphics.setShader(shaders.fontAlias)
				local txt = menu.textInputSelected and menu.textInputSelected == v and time%1 > 0.5 and v.val .. '|' or v.val
				love.graphics.print(txt, math.floor(v.x-v.font:getWidth(txt)/2), v.y)
				love.graphics.setShader()
			end
		end
	elseif menu.overlay.isOpen then
		love.graphics.setColor(255, 255, 255, 100)
		love.graphics.rectangle('fill', gsx/6, -(gsy*3/4)+(gsy*3/4)*ease.outQuart(math.min((time - menu.overlay.time)*6, 1)), gsx*2/3, gsy*3/4)
	elseif time - menu.overlay.time < 1/6 then
		love.graphics.setColor(255, 255, 255, 100)
		love.graphics.rectangle('fill', gsx/6, -gsy*3/4*ease.inQuart(math.min((time - menu.overlay.time)*6, 1)), gsx*2/3, gsy*3/4)
	end
end
