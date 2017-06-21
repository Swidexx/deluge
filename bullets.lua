
bullets = {
	paths = {},
	cbActive = 1
}

function bullets.update(dt)
	for i, v in pairs(objects.bullets) do
		if time - v.time > 3 then
			v.fixture:destroy()
			v.body:destroy()
			objects.bullets[i] = nil
		else
			bullets.cbActive = i
			physWorld:rayCast(v.lastPos.x, v.lastPos.y, v.body:getX(), v.body:getY(), bulletCallback)
			if v.hit then
				table.insert(bullets.paths[v.pathID], {time=time, x=v.hit.x, y=v.hit.y})
				--do something to v.hit.fixture
				if v.hit.type == 'enemy' then
					v.hit.fixture:getBody():applyLinearImpulse((v.body:getX()-v.lastPos.x)*5,
											(v.body:getY()-v.lastPos.y)*5, v.hit.x, v.hit.y)
					enemies.damage(v.hit.fixture:getUserData().table, 1)
				elseif v.hit.type == 'otherPlayer' then
					local dg = string.format('%s %s', 'damage', json.encode{
						type='player', id=v.hit.fixture:getUserData().id, val=1,
						direction={x=v.body:getX()-v.lastPos.x, y=v.body:getY()-v.lastPos.y}
					})
					client.udp:send(dg)
				end
				v.fixture:destroy()
				v.body:destroy()
				objects.bullets[i] = nil
			else
				table.insert(bullets.paths[v.pathID], {time=time, x=v.body:getX(), y=v.body:getY()})
				v.lastPos.x = v.body:getX()
				v.lastPos.y = v.body:getY()
			end
		end
	end
	--v[#v] can error ?
	for i, v in pairs(bullets.paths) do
		if not v[#v] or time - v[#v].time > 3 then
			bullets.paths[i] = nil
		end
	end
end

function bulletCallback(fixture, x, y, xn, yn, fraction)
	if type(fixture:getUserData()) == 'table' then
		local v = objects.bullets[bullets.cbActive]
		local type = fixture:getUserData().type
		if type == 'tile' or type == 'wall' or type == 'enemy' or
		v.fromPlayer and type == 'otherPlayer' and fixture:getUserData().id ~= player.id
		or not v.fromPlayer and type == 'player' then
			if not v.hit or fraction < v.hit.dist then
				v.hit = {
					dist = fraction,
					fixture = fixture,
					type = type,
					x = x,
					y = y
				}
			end
		end
	end
	return -1
end

function bullets.spawn(fromPlayer, x, y, a, s)
	local t = {
		fromPlayer = fromPlayer,
		time = time,
		body = love.physics.newBody(physWorld, x, y, 'dynamic'),
		lastPos = {x=x, y=y},
		shape = love.physics.newCircleShape(1)
	}
	t.fixture = love.physics.newFixture(t.body, t.shape, 20)
	t.fixture:setUserData{type='bullet'}
	t.fixture:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
	t.body:setLinearVelocity(math.cos(a)*s, math.sin(a)*s)
	table.insert(bullets.paths, {})
	table.insert(bullets.paths[#bullets.paths], {time=time, x=x, y=y})
	t.pathID = #bullets.paths
	table.insert(objects.bullets, t)
	if fromPlayer then
		local dg = string.format('%s %s', 'addBullet', json.encode{
			x=x, y=y, a=a, s=s
		})
		client.udp:send(dg)
	end
end

function bullets.draw()
	for _, v in pairs(bullets.paths) do
		for i2, v2 in pairs(v) do
			if i2 ~= #v then
				love.graphics.setColor(240, 240, 240, math.max(v2.time + 1/16 - time, 0)*16*255)
				love.graphics.line(v2.x, v2.y, v[i2+1].x, v[i2+1].y)
			end
		end
	end
	love.graphics.setColor(128, 128, 128)
	for _, v in pairs(objects.bullets) do
		love.graphics.circle('fill', v.body:getX(), v.body:getY(), 0.5)
	end
end
