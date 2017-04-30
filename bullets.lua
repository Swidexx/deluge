
bullets = {
	paths = {}
}

function bullets.update(dt)
	for i, v in pairs(objects.bullets) do
		if v.fixture:isDestroyed() then
			table.insert(bullets.paths[v.pathID], {time=time, x=v.body:getX(), y=v.body:getY()})
			v.body:destroy()
			objects.bullets[i] = nil
		elseif time - v.time > 3 then
			v.fixture:destroy()
			v.body:destroy()
			objects.bullets[i] = nil
		else
			table.insert(bullets.paths[v.pathID], {time=time, x=v.body:getX(), y=v.body:getY()})
		end
	end
	--v[#v] can error ?
	--[[
	for i, v in pairs(bullets.paths) do
		if time - v[#v].time > 3 then
			bullets.paths[i] = nil
		end
	end
	]]
end

function spawnBullet(x, y, a, s)
	local t = {
		time = time,
		body = love.physics.newBody(physWorld, x, y, 'dynamic'),
		shape = love.physics.newCircleShape(1)
	}
	t.fixture = love.physics.newFixture(t.body, t.shape, 20)
	t.fixture:setUserData{type='bullet'}
	t.fixture:setCategory(2)
	t.fixture:setMask(2)
	t.body:setBullet(true)
	t.body:setLinearVelocity(math.cos(a)*s, math.sin(a)*s)
	table.insert(bullets.paths, {})
	table.insert(bullets.paths[#bullets.paths], {time=time, x=x, y=y})
	t.pathID = #bullets.paths
	table.insert(objects.bullets, t)
end

function bullets.draw()
	for _, v in pairs(bullets.paths) do
		for i2, v2 in pairs(v) do
			if i2 ~= #v then
				love.graphics.setColor(240, 240, 40, math.max(v2.time + 0.5 - time, 0)*2*255)
				love.graphics.line(v2.x, v2.y, v[i2+1].x, v[i2+1].y)
			end
		end
	end
	love.graphics.setColor(0, 0, 0)
	for _, v in pairs(objects.bullets) do
		love.graphics.circle('fill', v.body:getX(), v.body:getY(), 1)
	end
end
