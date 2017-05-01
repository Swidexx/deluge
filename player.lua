
player = {
	getX = function() return objects.player.body:getX() end,
	getY = function() return objects.player.body:getY() end,
	anim = {
		state = 0,
		direction = 1,
		stopped = true
	},
	direction = 1
}

function player.update(dt)
	if love.keyboard.isDown('d') then
		objects.player.body:applyForce(1e3, 0)
		player.anim.stopped = false
		player.anim.direction = 1
	end
	if love.keyboard.isDown('a') then
		objects.player.body:applyForce(-1e3, 0)
		player.anim.stopped = false
		player.anim.direction = 1
	end
	if not love.keyboard.isDown('d') and not love.keyboard.isDown('a') then
		player.anim.direction = player.anim.state < #anim.player.walk.ids/2 and 1 or -1
	end

	local xv, yv = objects.player.body:getLinearVelocity()
	objects.player.body:setLinearVelocity(math.min(math.max(xv, -100), 100), yv)
	objects.player.body:applyForce(-8*xv, 0)

	if not player.anim.stopped then
		player.anim.state = (player.anim.state + math.max(math.abs(xv), 20)*0.5*player.anim.direction*dt - 1)%(#anim.player.walk.ids-1) + 1
		if math.floor(player.anim.state) == #anim.player.walk.ids then
			player.anim.stopped = true
		end
	end
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
	local xv, yv = objects.player.body:getLinearVelocity()
	if k == 'space' then
		objects.player.body:setLinearVelocity(xv, -2.5e2)
	end
end

function player.draw()
	love.graphics.setColor(255, 255, 255)
	local quadID = anim.player.walk.ids[math.floor(player.anim.state % #anim.player.walk.ids)+1]
	love.graphics.draw(gfx.player.walkSheet, anim.player.walk.quads[quadID], player.getX(), player.getY(), 0, player.direction, 1, 7, 13)
end
