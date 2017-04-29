hud = {}

function hud.set()
  health = 100
end

function hud.update(dt)

	if love.keyboard.isDown('up') then
		health = health + 1
  elseif love.keyboard.isDown('down') then
		health = health - 1
	end

  if health > 90 then
    face = {0,255,0}
  elseif health > 80 then
    face = {51,255,0}
  elseif health > 70 then
    face = {102,255,0}
  elseif health > 60 then
    face = {153,255,0}
  elseif health > 50 then
    face = {204,255,0}
  elseif health > 40 then
    face = {255,204,0}
  elseif health > 30 then
    face = {255,153,0}
  elseif health > 20 then
    face = {255,102,0}
  elseif health > 10 then
    face = {255,51,0}
  elseif health > -1 then
    face = {255,0,0}
  end
end

function hud.draw()
	love.graphics.setColor(face)
	love.graphics.rectangle('fill', 0, 0, 50, 50)
end
