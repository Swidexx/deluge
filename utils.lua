
function round(x)
	return math.floor(x + 0.5)
end

function lerp(a, b, t)
	return a + (b - a) * t
end

function buildID(name, postfix)
	return name .. (postfix ~= 0 and '(' .. postfix .. ')' or '')
end

function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

function setPlayerVals(p, v)
	p.x = v.x
	p.y = v.y
	p.direction = v.direction
	p.anim = p.anim or {}
	p.anim.state = v.anim.state
	p.anim.frame = v.anim.frame
	p.grapple = p.grapple or {}
	p.grapple.on = v.grapple.on
	p.grapple.x = v.grapple.x
	p.grapple.y = v.grapple.y
	p.holdingStaff = v.holdingStaff
end

function setEnemyVals(e, v)
	e.type = v.type
	e.x = v.x
	e.y = v.y
	e.r = v.r
	e.direction = v.direction
	e.hp = v.hp
	e.hpMax = v.hpMax
	e.lastHit = v.lastHit
	e.anim = e.anim or {}
	if v.anim then
		e.anim.state = v.anim.state
		e.anim.frame = v.anim.frame
	end
end
