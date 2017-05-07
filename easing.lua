
easing = {
	quadI = function (t) return t*t end,
	quadO = function (t) return t*(2-t) end,
	quadIO = function (t) return t<0.5 and 2*t*t or (4-2*t)*t-1 end,
	cubicI = function (t) return t*t*t end,
	cubicO = function (t) return (t-1)*(t-1)*(t-1)+1 end,
	cubicIO = function (t) return t<0.5 and 4*t*t*t or (t-1)*(2*t-2)*(2*t-2)+1 end,
	quartI = function (t) return t*t*t*t end,
	quartO = function (t) return 1-(t-1)*(t-1)*(t-1)*(t-1) end,
	quartIO = function (t) return t<0.5 and 8*t*t*t*t or 1-8*(t-1)*(t-1)*(t-1)*(t-1) end,
	quintI = function (t) return t*t*t*t*t end,
	quintO = function (t) return 1+(t-1)*(t-1)*(t-1)*(t-1)*(t-1) end,
	quintIO = function (t) return t<0.5 and 16*t*t*t*t*t or 1+16*(t-1)*(t-1)*(t-1)*(t-1)*(t-1) end,
}
