
enemies = {}

function addEnemy(info)
	local t = {
		x = info.x or 0,
		y = info.y or 0,
		name = info.name or 'Noname',
		type = info.type or 'none',
	}
	t.body = love.physics.newBody(physWorld, t.x, t.y, 'dynamic')
	t.shape = love.physics.newRectangleShape(16, 24)
	t.fixture = love.physics.newFixture(t.body, t.shape, 1)
	--t.body:setFixedRotation(true)
	table.insert(objects.enemies, t)
end

addEnemy{x=150, y=100, name='Dummy', type='dummy'}

function enemies.update(dt)

end

function enemies.draw()
	love.graphics.setColor(255, 255, 255)
	for _, v in ipairs(objects.enemies) do
		love.graphics.draw(gfx.enemies.dummy, v.body:getX(), v.body:getY(), v.body:getAngle(), 1, 1, 8, 12)
	end
end
