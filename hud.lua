
hud = {
	face = gfx.hud.health1
}

function hud.update(dt)
	if love.keyboard.isDown('up') then
		player.health = player.health + dt*5
	elseif love.keyboard.isDown('down') then
		player.health = player.health - dt*5
	end
	if player.health > 3 then
		hud.face = gfx.hud.health1
	elseif player.health > 2 then
		hud.face = gfx.hud.health2
	elseif player.health > 1 then
		hud.face = gfx.hud.health3
	elseif player.health > 0 then
		hud.face = gfx.hud.health4
	else
		hud.face = gfx.hud.health5
	end
end

function hud.draw()
	love.graphics.setColor(255, 255, 255, 200)
	love.graphics.draw(gfx.hud.inventory, 0, 0)
	love.graphics.setColor(128, 128, 255, 200)
	love.graphics.rectangle('fill', 1, 66 + player.inventory.selected*19, 19, 18)
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(hud.face, -3, 4)
	love.graphics.draw(gfx.items.gun, 10, 66+1*19+9, 0, 1, 1, 8, 8)
	love.graphics.draw(gfx.items.radiantStaff, 10, 66+2*19+9, 0, 1, 1, 8, 8)
end
