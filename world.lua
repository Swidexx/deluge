
world = {}

chestState = 1
function world.update(dt)
	physWorld:update(dt)
	if (player:getX()-1488)^2+(player:getY()-1120)^2 < 48^2 then
		chestState = math.min(chestState + dt*8, 10)
	else
		chestState = math.max(chestState - dt*8, 1)
	end
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
			drawColliders(v)
		end
    end
end

function world.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(gfx.map, 0, 0)
	love.graphics.draw(gfx.objects.chestSheet, anim.objects.chest.quads[math.floor(chestState)], 1488, 1120, 0, 1, 1, 16, 32)

	--drawColliders()
end
