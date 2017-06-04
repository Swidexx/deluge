
menu = {
	state = 'main',
	sliderHeld = {},
	btns = {}
}

function setSFXVolume(n)
	for _, v in pairs(sfx) do
		v:setVolume(n)
	end
end

function setMusicVolume(n)
	for _, v in pairs(music) do
		v:setVolume(n)
	end
end

function menu.addButton(t)
	local img = t.img or gfx.menu.play
	local x = t.x and t.x - img:getWidth()/2 or gsx/2 - img:getWidth()/2
	x = math.floor(x)
	local y = t.y and t.y - img:getHeight()/2 or gsy/2 - img:getHeight()/2
	y = math.floor(y)
	local val = t.val
	if not val and (t.type == 'switch' or t.type == 'slider' or t.type == 'cycle') then
		val = 0
	end
	local width = t.width
	if not width and t.type == 'slider' then
		width = img:getWidth()+2
	end
	local numvals = t.numvals
	if not numvals and t.type == 'cycle' then
		numvals = 2
	end
	local state = t.state or 'main'
	if not menu.btns[state] then menu.btns[state] = {} end
	menu.btns[state][#menu.btns[state]+1] = {img=img, id=t.id, type=t.type, val=val, width=width, numvals=numvals, held=false, x=x, y=y}
end
menu.addButton{img=gfx.menu.title, type='static', y=40}
menu.addButton{img=gfx.menu.play, id='play', y=140}
menu.addButton{img=gfx.menu.options, id='options', y=180}
menu.addButton{img=gfx.menu.exit, id='exit', y=230}
menu.addButton{state='options', img=gfx.menu.volume, id='volume', type='slider', val=0.07, y=50}
love.audio.setVolume(0.07)
menu.addButton{state='options', img=gfx.menu.sfx, id='sfx', type='slider', val=0.7, width=56, x=gsx/2-30, y=70}
setSFXVolume(0.7)
menu.addButton{state='options', img=gfx.menu.music, id='music', type='slider', val=0.7, width=56, x=gsx/2+30, y=70}
setMusicVolume(0.7)
menu.addButton{state='options', img=gfx.menu.fullscreen, id='fullscreen', type='switch', val=0, y=130}
menu.addButton{state='options', img=gfx.menu.windowsize, id='windowsize', type='cycle', val=2, numvals=4, y=150}
menu.addButton{state='options', img=gfx.menu.back, id='back', y=230}


function menu.mousepressed(x, y, btn)
	local mx, my = screen2game(love.mouse.getPosition())
	for i, v in pairs(menu.btns[menu.state]) do
		if (v.type ~= 'static' and v.type ~= 'slider') and mx > v.x and mx < v.x+v.img:getWidth() and my > v.y and my < v.y+v.img:getHeight() then
			if v.id == 'play' then
				gamestate = 'playing'
				music.strategy:stop()
				music.rhymull:play()
				sfx.select:clone():play()
			elseif v.id == 'options' then
				menu.state = 'options'
				sfx.select:clone():play()
			elseif v.id == 'exit' then
				love.event.quit()
				sfx.select:clone():play()
			elseif v.id == 'back' then
				menu.state = 'main'
				sfx.select:clone():play()
			elseif v.id == 'fullscreen' then
				love.window.setFullscreen(not love.window.getFullscreen())
				v.val = 1-v.val
				sfx.select:clone():play()
			elseif v.id == 'windowsize' and not love.window.getFullscreen() then
				v.val = (v.val+1)%v.numvals
				_, _, flags = love.window.getMode()
				local w, h = gsx*(v.val+1), gsy*(v.val+1)
				love.window.setMode(w, h, flags)
				love.resize(w, h)
				setShaderDefaults()
				sfx.select:clone():play()
			end
			break
		elseif v.type == 'slider' and mx > v.x+v.img:getWidth()/2-v.width/2 and mx < v.x+v.img:getWidth()/2+v.width/2 and my > v.y and my < v.y+v.img:getHeight() then
			menu.sliderHeld = {state=menu.state, id=i}
			break
		end
	end
end

function menu.mousereleased(x, y, btn)
	menu.sliderHeld.id = nil
end

function menu.keypressed(k)
	if k == 'escape' then
		if menu.state == 'main' then
			--love.event.quit()
		elseif menu.state == 'options' then
			menu.state = 'main'
		end
	end
end

function menu.draw()
	local mx, my = screen2game(love.mouse.getPosition())
	if menu.sliderHeld.state == menu.state and menu.sliderHeld.id then
		local v = menu.btns[menu.sliderHeld.state][menu.sliderHeld.id]
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
		if ((v.type ~= 'static' and v.type ~= 'slider') and mx > v.x and mx < v.x+v.img:getWidth() or
		v.type == 'slider' and mx > v.x+v.img:getWidth()/2-v.width/2 and mx < v.x+v.img:getWidth()/2+v.width/2) and my > v.y and my < v.y+v.img:getHeight() then
			love.graphics.setColor(255, 255, 255, 200)
		else
			love.graphics.setColor(255, 255, 255)
		end
		if v.id == 'windowsize' and love.window.getFullscreen() then
			love.graphics.setColor(255, 255, 255, 100)
		end
		love.graphics.draw(v.img, v.x, v.y)
		if v.type == 'switch' and v.val ~= 0 then
			love.graphics.setColor(0, 0, 0, 32)
			love.graphics.rectangle('fill', math.floor(v.x), math.floor(v.y), v.img:getWidth(), v.img:getHeight())
		elseif v.type == 'slider' then
			love.graphics.setColor(0, 0, 0, 64)
			love.graphics.setLineWidth(1)
			love.graphics.rectangle('line', math.floor(v.x+v.img:getWidth()/2-v.width/2), math.floor(v.y-1), v.width, v.img:getHeight()+2)
			love.graphics.setColor(0, 0, 0, 32)
			love.graphics.rectangle('fill', math.floor(v.x+v.img:getWidth()/2-v.width/2+1), math.floor(v.y), (v.width-3)*v.val, v.img:getHeight()-1)
		elseif v.type == 'cycle' then
			love.graphics.setColor(0, 0, 0, 32)
			love.graphics.rectangle('fill', math.floor(v.x), math.floor(v.y+4), v.img:getWidth()*(v.val+1)/v.numvals, v.img:getHeight()-8)
		end
	end
end
