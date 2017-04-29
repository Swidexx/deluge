
world = {}

function world.update(dt)
	physWorld:update(dt)
end

function drawColliders(e)
	e = e or objects
	if e.shape then
		love.graphics.setColor(0, 0, 200, 100)
		if e.shape:getType() == 'polygon' then
			local points = {e.body:getWorldPoints(e.shape:getPoints())}
			love.graphics.polygon('fill', points)
		elseif e.shape:getType() == 'circle' then
			love.graphics.circle('fill', e.body:getX(), e.body:getY(), e.shape:getRadius())
		else
			print('unknown shape type')
		end
    else
		for _, v in pairs(e) do
			drawColliders(v)
		end
    end
end

function world.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(gfx.map, 0, 0)
	--drawColliders()
end
