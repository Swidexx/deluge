
enemies = {}

-- todo: circle collision with rectangle sensor
function addEnemy(info)
	local t = {
		x = info.x or 0,
		y = info.y or 0,
		name = info.name or 'Noname',
		type = info.type or 'none',
		lastHit = -10,
		hp = info.hp or 10,
		hpMax = info.hpMax or 10
	}
	t.body = love.physics.newBody(physWorld, t.x, t.y, 'dynamic')
	t.shape = love.physics.newRectangleShape(16, 24)
	t.fixture = love.physics.newFixture(t.body, t.shape, 1)
	t.fixture:setUserData{type='enemy', enemyType=t.type, table=t}
	table.insert(objects.enemies, t)
end

addEnemy{x=1345, y=1000, name='Dummy', type='dummy'}

function enemies.update(dt)
	for _, v in pairs(objects.enemies) do
		v.body:applyTorque(-v.body:getAngle()*5e4)
		local xv, yv = v.body:getLinearVelocity()
		v.body:setLinearVelocity(math.min(math.max(xv, -80), 80), yv)
		v.body:applyForce(-8*xv, 0)
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
		love.graphics.draw(gfx.enemies.dummy, v.body:getX(), v.body:getY(), v.body:getAngle(), 1, 1, 8, 12)
		love.graphics.setColor(0, 0, 0, math.max(-((time - v.lastHit)*2 - 1)^2 + 1, 0)*255)
		love.graphics.setFont(fonts.f18)
		love.graphics.print('!', math.floor(v.body:getX() - fonts.f18:getWidth('!')/2),
							math.floor(v.body:getY() - 12 - fonts.f18:getHeight('!') - math.max(-((time - v.lastHit)*2 - 1)^2 + 1, 0)*8))
		love.graphics.setColor(255, 0, 0)
		love.graphics.rectangle('fill', math.floor(v.body:getX() - 8 + 0.5), math.floor(v.body:getY() + 16 + 0.5), 16, 4)
		love.graphics.setColor(0, 255, 0)
		love.graphics.rectangle('fill', math.floor(v.body:getX() - 8 + 0.5), math.floor(v.body:getY() + 16 + 0.5), math.floor(16*v.hp/v.hpMax), 4)
		love.graphics.setColor(0, 0, 0)
		love.graphics.setLineWidth(1)
		love.graphics.rectangle('line', math.floor(v.body:getX() - 8 + 0.5), math.floor(v.body:getY() + 16 + 0.5), 16, 4)
	end
end
