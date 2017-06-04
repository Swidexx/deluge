extern Image airMask;
extern Image sunLightMap;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	vec4 air = Texel(airMask, texture_coords);
    vec4 light = Texel(sunLightMap, texture_coords);
	vec4 tex = Texel(texture, texture_coords);
	return air.r > 0.5 ? max(light, tex) : vec4(vec3(0.0), 1.0);
}
