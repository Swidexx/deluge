
player = {
	getX = function() return objects.player.body:getX() end,
	getY = function() return objects.player.body:getY() end
}

function player.update(dt)
	if love.keyboard.isDown('d') then
		objects.player.body:applyForce(4e2, 0)
	end
	if love.keyboard.isDown('a') then
		objects.player.body:applyForce(-4e2, 0)
	end

	local xv, yv = objects.player.body:getLinearVelocity()
	objects.player.body:applyForce(-2*xv, 0)
end

function player.shoot(x, y)
	x, y = screen2game(x, y)
	x, y = x-gsx/2, y-gsy/2
	local a = math.atan2(x, y)
	--todo: disable collision with player
	--spawnBullet(player.getX(), player.getY(), a, 2e3)
end

function player.draw()
	love.graphics.setColor(64, 128, 64)
	local points = {objects.player.body:getWorldPoints(objects.player.shape:getPoints())}
	love.graphics.polygon('fill', points)
end
