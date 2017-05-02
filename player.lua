
player = {
	getX = function() return objects.player.body:getX() end,
	getY = function() return objects.player.body:getY() end,
	anim = {
		frame = 1,
		nextFrame = 1,
		frameTime = 0
	},
	direction = 1,
	inAir = true,
	walking = false
}

function player.update(dt)
	local xv, yv = objects.player.body:getLinearVelocity()

	objects.player.body:setLinearVelocity(math.min(math.max(xv, -100), 100), yv)
	objects.player.body:applyForce(-8*xv, 0)

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
	player.walking = false
	if love.keyboard.isDown('d') or love.keyboard.isDown('a') then
		player.walking = true
	end

	if math.abs(xv) > 10 then
		player.direction = xv < 0 and -1 or 1
	end

	local jumpContacts = objects.playerSensorDown.body:getContactList()
	player.inAir = true
	for _, v in pairs(jumpContacts) do
		if v:isTouching() then
			local fixA, fixB = v:getFixtures()
			local ud = fixB:getUserData()
			if type(ud) == 'table' then
				if not (ud.type == 'bullet' or ud.type == 'player') then
					player.inAir = false
				end
				if ud.type == 'enemy' then
					player.jump()
					ud.table.lastHit = time
				end
			else
				player.inAir = false
			end
		end
	end

	if player.walking then
		player.anim.frameTime = player.anim.frameTime + math.max(math.abs(xv), 20)*0.5*dt
		player.anim.nextFrame = player.anim.frame + 1
	else
		player.anim.frameTime = player.anim.frameTime + 10*dt
		if player.anim.nextFrame ~= 1 then
			player.anim.nextFrame = player.anim.frame + (player.anim.frame > 6 and 1 or -1)
		end
	end
	if player.anim.nextFrame > 9 then
		player.anim.nextFrame = 3
	elseif player.anim.nextFrame < 1 then
		player.anim.nextFrame = 1
	end
	if player.anim.frameTime > 1 then
		player.anim.frameTime = player.anim.frameTime - 1
		player.anim.frame = player.anim.nextFrame
	end
end

function player.jump()
	local xv, yv = objects.player.body:getLinearVelocity()
	objects.player.body:setLinearVelocity(xv, -2.5e2)
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
	if k == 'space' and not player.inAir then
		player.jump()
	end
end

function player.draw()
	love.graphics.setColor(255, 255, 255)
	local quad = anim.player.walk.quads[player.anim.frame]
	local _, _, w, h = quad:getViewport()
	love.graphics.draw(gfx.player.walkSheet, quad, player.getX(), player.getY(),
						0, player.direction, 1, math.floor(w/2), math.floor(h/2))
end
