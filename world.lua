
world = {}

function world.update(dt)
	physWorld:update(dt)
end

function world.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(gfx.map, 0, 0)
end
