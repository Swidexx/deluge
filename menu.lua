
menu = {}
menu.state = 'main'

menu.btns = {}
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
menu.addButton{state='options', img=gfx.menu.volume, id='volume', type='slider', val=0.7, y=50}
menu.addButton{state='options', img=gfx.menu.sfx, id='sfx', type='slider', val=0.7, width=56, x=gsx/2-30, y=70}
menu.addButton{state='options', img=gfx.menu.music, id='music', type='slider', val=0.7, width=56, x=gsx/2+30, y=70}
menu.addButton{state='options', img=gfx.menu.fullscreen, id='fullscreen', type='switch', val=0, y=130}
menu.addButton{state='options', img=gfx.menu.windowsize, id='windowsize', type='cycle', val=2, numvals=4, y=150}
menu.addButton{state='options', img=gfx.menu.back, id='back', y=230}


function menu.mousepressed(x, y, btn)
	for i, v in pairs(menu.btns[menu.state]) do
		if mx > v.x and mx < v.x+v.img:getWidth() and my > v.y and my < v.y+v.img:getHeight() then
			if v.id == 'play' then
				gamestate = 'playing'
			elseif v.id == 'options' then
				menu.state = 'options'
			elseif v.id == 'exit' then
				love.event.quit()
			elseif v.id == 'back' then
				menu.state = 'main'
			elseif v.id == 'fullscreen' then
				love.window.setFullscreen(not love.window.getFullscreen())
				v.val = 1-v.val
			elseif v.id == 'windowsize' and not love.window.getFullscreen() then
				v.val = (v.val+1)%v.numvals
				_, _, flags = love.window.getMode()
				local w, h = gsx*(v.val+1), gsy*(v.val+1)
				love.window.setMode(w, h, flags)
				love.resize(w, h)
			end
			break
		end
	end
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
	love.graphics.setShader(shaders.menubg)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', 0, 0, gsx, gsy)
	love.graphics.setShader()
	for i, v in pairs(menu.btns[menu.state]) do
		if mx > v.x and mx < v.x+v.img:getWidth() and my > v.y and my < v.y+v.img:getHeight() and v.type ~= 'static' then
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
