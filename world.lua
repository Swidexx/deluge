
world = {}

chestState = 1
function world.update(dt)
	physWorld:update(dt)
	local lastState = chestState
	if (player:getX()-1488)^2+(player:getY()-1120)^2 < 48^2 then
		chestState = math.min(chestState + dt*8, 10)
	else
		chestState = math.max(chestState - dt*8, 1)
	end
	if chestState == 10 and lastState ~= chestState then
		player.health = 4
		sfx.heal:clone():play()
	end
end

function world.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(gfx.map, 0, 0)
	for i, v in pairs(bakedLights) do
		if i > 2 then
			love.graphics.draw(gfx.torch, v[1], v[2], 0, 1, 1, gfx.torch:getWidth()/2, gfx.torch:getHeight()/2)
		end
	end
	love.graphics.draw(gfx.objects.chestSheet, anim.objects.chest.quads[math.floor(chestState)], 1488, 1120, 0, 1, 1, 16, 32)
	logger.drawColliders()
end
