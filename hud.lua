hud = {}

function hud.set()
  health = 5
end

function hud.update(dt)

	if love.keyboard.isDown('up') then
		health = health + 0.1
  elseif love.keyboard.isDown('down') then
		health = health - 0.1
	end

  if health > 4 then
    face = gfx.hud.health1
  elseif health > 3 then
    face = gfx.hud.health2
  elseif health > 2 then
    face = gfx.hud.health3
  elseif health > 1 then
    face = gfx.hud.health4
  elseif health > -1 then
    face = gfx.hud.health5
  end
end

function hud.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(gfx.hud.inventory, 0, 0)
	love.graphics.draw(face, -3, 4)
end
