
player = {
	getX = function() return objects.player.body:getX() end,
	getY = function() return objects.player.body:getY() end,
	health = 4,
	anim = {
		state = 'jump',
		frame = 8,
		nextFrame = 1,
		frameTime = 0
	},
	direction = 1,
	inAir = true,
	inAirLast = true,
	jumped = true,
	walking = false,
	lastEnemyJump = 0,
	grapple = {
		found = false,
		dist = 0,
		fixture = nil,
		x = 0, y = 0
	}
}

function player.respawn()
	player.health = 4
	objects.player.body:setPosition(1260, 1000)
	objects.playerSensorDown.body:setPosition(1260, 1017)
end

function player.update(dt)
	local xv, yv = objects.player.body:getLinearVelocity()

	--objects.player.body:setLinearVelocity(math.min(math.max(xv, -100), 100), yv)
	if not player.inAir then
		objects.player.body:applyForce(-8*xv, 0)
	end

	if love.keyboard.isDown('d') and xv < 100 then
		objects.player.body:applyForce(1e3, 0)
		player.anim.stopped = false
		player.anim.direction = 1
	end
	if love.keyboard.isDown('a') and xv > -100 then
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
	player.lastInAir = player.inAir
	player.inAir = true
	for _, v in pairs(jumpContacts) do
		if v:isTouching() then
			local fixA, fixB = v:getFixtures()
			local ud = fixB:getUserData()
			if type(ud) == 'table' then
				if not (ud.type == 'bullet' or ud.type == 'player' or ud.type == 'enemy') then
					player.inAir = false
				end
				if ud.type == 'enemy' then
					if time - player.lastEnemyJump > 0.1 then
						player.lastEnemyJump = time
						player.jump()
						enemies.damage(ud.table, 4)
					end
				end
			else
				player.inAir = false
			end
		end
	end

	if player.lastInAir and not player.inAir then
		player.jumped = false
		sfx.land:clone():play()
	end

	if player.anim.state ~= 'jump' then
		if player.inAir then
			player.anim.state = 'jump'
			player.anim.frame = 4
		end
	end
	if player.anim.state == 'walk' then
		if player.walking then
			--player.anim.frameTime = player.anim.frameTime + math.max(math.abs(xv), 20)*0.5*dt
			player.anim.frameTime = player.anim.frameTime + 20*dt
			player.anim.nextFrame = player.anim.frame + 1
		else
			player.anim.frameTime = player.anim.frameTime + 10*dt
			if player.anim.nextFrame ~= 1 then
				player.anim.nextFrame = player.anim.frame + (player.anim.frame > 7 and 1 or -1)
			end
		end
		if player.anim.nextFrame > 16 then
			player.anim.nextFrame = 3
		elseif player.anim.nextFrame < 1 then
			player.anim.nextFrame = 1
		end
	elseif player.anim.state == 'jump' then
		if player.inAir then
			player.anim.frameTime = player.anim.frameTime + 20*dt
			player.anim.nextFrame = math.min(player.anim.frame + 1, 8)
		else
			player.anim.frameTime = player.anim.frameTime + 40*dt
			player.anim.nextFrame = player.anim.frame - 1
			if player.anim.nextFrame < 4 then
				player.anim.frame = 3
				player.anim.state = 'walk'
			end
		end
	end

	if player.anim.frameTime > 1 then
		player.anim.frameTime = math.min(player.anim.frameTime - 1, 1)
		player.anim.frame = player.anim.nextFrame
		if player.anim.state == 'walk' and (player.anim.frame == 9 or player.anim.frame == 16) then
			sfx.step:clone():play()
		end
	end
end

function player.jump()
	if objects.player.grappleJoint then
		objects.player.grappleJoint:destroy()
		objects.player.grappleJoint = nil
	end
	player.grapple.found = false
	local xv, yv = objects.player.body:getLinearVelocity()
	objects.player.body:setLinearVelocity(xv, -2.5e2)
	player.jumped = true
	sfx.jump:clone():play()
end

function player.damage(d)
	player.health = player.health - d
	sfx.hitHurt:clone():play()
	if player.health <= 0 then
		sfx.death:clone():play()
		player.respawn()
	end
end

function player.mousepressed(x, y, btn)
	x, y = screen2game(x, y)
	x, y = camera.x + x - player.getX(), camera.y + y - player.getY()
	local a = math.atan2(x, -y)-math.pi/2
	if btn == 1 then
		spawnBullet(player.getX(), player.getY(), a, 1.2e3)
		player.direction = x < 0 and -1 or 1
		sfx.laser:clone():play()
	elseif btn == 2 then
		player.grapple.found = false
		physWorld:rayCast(player.getX(), player.getY(), player.getX() + math.cos(a)*150,
							player.getY() + math.sin(a)*150, grappleCallback)
		if player.grapple.found then
			if objects.player.grappleJoint then
				objects.player.grappleJoint:destroy()
				objects.player.grappleJoint = nil
			end
			objects.player.grappleJoint = love.physics.newRopeJoint(objects.player.body,
					player.grapple.fixture:getBody(), player.getX(), player.getY(),
					player.grapple.x, player.grapple.y,
					math.sqrt((player.getX()-player.grapple.x)^2+(player.getY()-player.grapple.y)^2), true)
			sfx.select:clone():play()
		end
	end
end

function grappleCallback(fixture, x, y, xn, yn, fraction)
	if type(fixture:getUserData()) == 'table' and fixture:getUserData().type == 'tile' then
		if fraction < player.grapple.dist or not player.grapple.found then
			player.grapple.found = true
			player.grapple.dist = fraction
			player.grapple.fixture = fixture
			player.grapple.x = x
			player.grapple.y = y
		end
	end
	return -1
end

function player.keypressed(k, scancode, isrepeat)
	local xv, yv = objects.player.body:getLinearVelocity()
	if k == 'space' then
		if player.inAir and objects.player.grappleJoint then
			objects.player.grappleJoint:destroy()
			objects.player.grappleJoint = nil
			player.jump()
		elseif not player.jumped then
			player.jump()
		end
	end
end

function player.draw()
	love.graphics.setColor(255, 255, 255)
	if player.anim.state == 'walk' then
		local quad = anim.player.walk.quads[player.anim.frame]
		local _, _, w, h = quad:getViewport()
		love.graphics.draw(gfx.player.walkSheet, quad, player.getX(), player.getY(),
							0, player.direction, 1, math.floor(w/2), math.floor(h/2))
	elseif player.anim.state == 'jump' then
		local quad = anim.player.jump.quads[player.anim.frame]
		local _, _, w, h = quad:getViewport()
		love.graphics.draw(gfx.player.jumpSheet, quad, player.getX(), player.getY(),
							0, player.direction, 1, math.floor(w/2), math.floor(h/2))
	end
	if player.grapple.found then
		love.graphics.setLineWidth(1)
		love.graphics.setColor(255, 0, 0)
		local a = math.atan2(player.grapple.x - player.getX(), player.getY() - player.grapple.y) - math.pi/2
		love.graphics.line(player.getX(), player.getY(), player.getX() + math.cos(a)*150, player.getY() + math.sin(a)*150)
		love.graphics.setColor(0, 0, 0)
		love.graphics.circle('line', player.grapple.x, player.grapple.y, 3)
	end
end
