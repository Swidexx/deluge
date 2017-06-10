
enemies = {}

function addEnemy(info)
	local t = {
		x = info.x or 0,
		y = info.y or 0,
		name = info.name or 'Noname',
		type = info.type or 'none',
		lastHit = -10,
		hp = info.hp or 10,
		hpMax = info.hpMax or 10,
		inAir = true,
		lastJump = -10,
		lastAttackJump = -10
	}
	t.main = {
		body = love.physics.newBody(physWorld, t.x, t.y, 'dynamic'),
		shape = love.physics.newRectangleShape(16, 24)
	}
	t.main.fixture = love.physics.newFixture(t.main.body, t.main.shape, 1)
	t.main.fixture:setUserData{type='enemy', enemyType=t.type, table=t}
	t.sensorDown = {
		body = love.physics.newBody(physWorld, t.x, t.y + 13, 'dynamic'),
		shape = love.physics.newRectangleShape(14, 1),
	}
	t.sensorDown.fixture = love.physics.newFixture(t.sensorDown.body, t.sensorDown.shape, 1)
	t.sensorDown.fixture:setUserData{type='enemySensorDown'}
	t.sensorDown.fixture:setSensor(true)
	t.sensorDown.joint = love.physics.newWeldJoint(t.main.body, t.sensorDown.body, t.x, t.y)
	table.insert(objects.enemies, t)
end

addEnemy{x=1345, y=1000, name='Dummy', type='dummy'}

function enemies.update(dt)
	for _, v in pairs(objects.enemies) do
		v.main.body:applyTorque(-v.main.body:getAngle()*5e4)
		local xv, yv = v.main.body:getLinearVelocity()
		v.main.body:setLinearVelocity(math.min(math.max(xv, -80), 80), yv)
		v.main.body:applyForce(-8*xv, 0)

		local jumpContacts = v.sensorDown.body:getContactList()
		v.inAir = true
		for _, v2 in pairs(jumpContacts) do
			if v2:isTouching() then
				local fixA, fixB = v2:getFixtures()
				-- fixA, fixB, or either?
				local ud = fixA:getUserData()
				if type(ud) == 'table' then
					if not (ud.type == 'bullet' or ud.type == 'enemy') then
						v.inAir = false
					end
					if ud.type == 'player' then
						if time - v.lastAttackJump > 0.2 then
							v.lastAttackJump = time
							v.main.body:setLinearVelocity(xv, -2.7e2)
							player.damage(1)
						end
					end
					--debug.log(ud.type)
				else
					v.inAir = false
				end
			end
		end

		if not v.inAir and time - v.lastJump > 1.5 then
			v.lastJump = time
			v.main.body:setLinearVelocity(xv, -2.7e2)
		end
	end
end

function enemies.damage(v, d)
	d = d or 1
	v.hp = math.max(v.hp - d, 0)
	v.lastHit = time
end

function enemies.draw()
	for _, v in ipairs(objects.enemies) do
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(gfx.enemies.dummy, v.main.body:getX(), v.main.body:getY(), v.main.body:getAngle(), 1, 1, 8, 12)
		love.graphics.setColor(0, 0, 0, math.max(-((time - v.lastHit)*2 - 1)^2 + 1, 0)*255)
		love.graphics.setFont(fonts.f18)
		love.graphics.print('!', math.floor(v.main.body:getX() - fonts.f18:getWidth('!')/2),
							math.floor(v.main.body:getY() - 12 - fonts.f18:getHeight('!') - math.max(-((time - v.lastHit)*2 - 1)^2 + 1, 0)*8))
		love.graphics.setColor(255, 0, 0)
		love.graphics.rectangle('fill', math.floor(v.main.body:getX() - 8 + 0.5), math.floor(v.main.body:getY() + 16 + 0.5), 16, 4)
		love.graphics.setColor(0, 255, 0)
		love.graphics.rectangle('fill', math.floor(v.main.body:getX() - 8 + 0.5), math.floor(v.main.body:getY() + 16 + 0.5), math.floor(16*v.hp/v.hpMax), 4)
		love.graphics.setColor(0, 0, 0)
		love.graphics.setLineWidth(1)
		love.graphics.rectangle('line', math.floor(v.main.body:getX() - 8 + 0.5), math.floor(v.main.body:getY() + 16 + 0.5), 16, 4)
	end
end
