
world = {}

function world.update(dt)
	physWorld:update(dt)
end

function drawColliders(e)
	e = e or objects
	if e.shape then
		love.graphics.setLineWidth(1)
		if e.shape:getType() == 'polygon' then
			local points = {e.body:getWorldPoints(e.shape:getPoints())}
			love.graphics.setColor(0, 0, 200, 50)
			love.graphics.polygon('fill', points)
			love.graphics.setColor(0, 0, 0, 100)
			love.graphics.polygon('line', points)
		elseif e.shape:getType() == 'circle' then
			love.graphics.setColor(0, 0, 200, 50)
			love.graphics.circle('fill', e.body:getX(), e.body:getY(), e.shape:getRadius())
			love.graphics.setColor(0, 0, 0, 100)
			love.graphics.circle('line', e.body:getX(), e.body:getY(), e.shape:getRadius())
		else
			print('unknown shape type')
		end
    else
		for _, v in pairs(e) do
			if type(v) == 'table' then
				drawColliders(v)
			end
		end
    end
end

function world.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(gfx.map, 0, 0)
	drawColliders()
end
