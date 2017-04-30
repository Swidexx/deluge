
player = {
	getX = function() return objects.player.body:getX() end,
	getY = function() return objects.player.body:getY() end,
	animState = 0,
	direction = 1
}

function player.update(dt)
	if love.keyboard.isDown('d') then
		objects.player.body:applyForce(4e2, 0)
	end
	if love.keyboard.isDown('a') then
		objects.player.body:applyForce(-4e2, 0)
	end

	local xv, yv = objects.player.body:getLinearVelocity()
	objects.player.body:setLinearVelocity(math.min(math.max(xv, -80), 80), yv)
	objects.player.body:applyForce(-2*xv, 0)

	player.animState = player.animState + math.abs(xv)*0.5*dt
	if math.abs(xv) > 10 then
		player.direction = xv < 0 and -1 or 1
	end
end

function player.shoot(x, y)
	x, y = screen2game(x, y)
	x, y = camera.x + x - player.getX(), camera.y + y - player.getY()
	local a = math.atan2(x, -y)-math.pi/2
	spawnBullet(player.getX(), player.getY(), a, 1.2e3)
	player.direction = x < 0 and -1 or 1
end

function player.keypressed(k, scancode, isrepeat)
	if k == 'space' then
		objects.player.body:applyForce(0, -12e3)
	end
end

function player.draw()
	love.graphics.setColor(255, 255, 255)
	local quadID = anim.player.walk.ids[math.floor(player.animState % #anim.player.walk.ids)+1]
	love.graphics.draw(gfx.player.walkSheet, anim.player.walk.quads[quadID], player.getX(), player.getY(), 0, player.direction, 1, 7, 13)
end
