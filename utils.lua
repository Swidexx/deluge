
function buildID(name, postfix)
	return name .. (postfix ~= 0 and '(' .. postfix .. ')' or '')
end

function lerp(a, b, t)
	return a + (b - a) * t
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
