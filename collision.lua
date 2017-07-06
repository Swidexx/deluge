
love.physics.setMeter(24)
serverWorld = love.physics.newWorld(0, 800, true)
clientWorld = love.physics.newWorld(0, 800, true)
objects = {
	server = {
		players = {},
		enemies = {},
		worldEdges = {
			left = {
				body = love.physics.newBody(serverWorld, -5, worldSize.y/2, 'static'),
				shape = love.physics.newRectangleShape(10, worldSize.y)
			},
			right = {
				body = love.physics.newBody(serverWorld, worldSize.x + 5, worldSize.y/2, 'static'),
				shape = love.physics.newRectangleShape(10, worldSize.y)
			},
			up = {
				body = love.physics.newBody(serverWorld, worldSize.x/2, -5, 'static'),
				shape = love.physics.newRectangleShape(worldSize.x, 10)
			},
			down = {
				body = love.physics.newBody(serverWorld, worldSize.x/2, worldSize.y + 5, 'static'),
				shape = love.physics.newRectangleShape(worldSize.x, 10)
			}
		},
		tiles = {},
	},
	client = {
		player = {
			body = love.physics.newBody(clientWorld, 1260, 1000, 'dynamic'),
			shape = love.physics.newRectangleShape(19, 33)
		},
		playerSensorDown = {
			body = love.physics.newBody(clientWorld, 1260, 1017, 'dynamic'),
			shape = love.physics.newRectangleShape(15, 1)
		},
		players = {},
		enemies = {},
		worldEdges = {
			left = {
				body = love.physics.newBody(clientWorld, -5, worldSize.y/2, 'static'),
				shape = love.physics.newRectangleShape(10, worldSize.y)
			},
			right = {
				body = love.physics.newBody(clientWorld, worldSize.x + 5, worldSize.y/2, 'static'),
				shape = love.physics.newRectangleShape(10, worldSize.y)
			},
			up = {
				body = love.physics.newBody(clientWorld, worldSize.x/2, -5, 'static'),
				shape = love.physics.newRectangleShape(worldSize.x, 10)
			},
			down = {
				body = love.physics.newBody(clientWorld, worldSize.x/2, worldSize.y + 5, 'static'),
				shape = love.physics.newRectangleShape(worldSize.x, 10)
			}
		},
		tiles = {},
		bullets = {}
	},
}

objects.client.player.fixture = love.physics.newFixture(objects.client.player.body, objects.client.player.shape, 1)
objects.client.player.fixture:setUserData{type='player'}
objects.client.player.fixture:setFriction(0)
objects.client.player.fixture:setCategory(2)
objects.client.player.fixture:setMask(2)
objects.client.player.body:setFixedRotation(true)

objects.client.playerSensorDown.fixture = love.physics.newFixture(objects.client.playerSensorDown.body, objects.client.playerSensorDown.shape, 1)
objects.client.playerSensorDown.fixture:setUserData{type='playerSensorDown'}
objects.client.playerSensorDown.fixture:setSensor(true)
objects.client.playerSensorDown.body:setFixedRotation(true)
objects.client.playerSensorDown.body:setGravityScale(0)

objects.client.player.sensorDownJoint = love.physics.newWeldJoint(objects.client.player.body, objects.client.playerSensorDown.body, 1260, 1000)
