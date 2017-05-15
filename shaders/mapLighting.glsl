extern Image airMask;
extern Image lightMap;
extern Image shadowMap;
extern vec2 camPos;
extern vec2 scale;
extern vec2 mapSize;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	vec4 air = Texel(airMask, texture_coords*scale + camPos/mapSize);
    vec4 light = Texel(lightMap, texture_coords*scale + camPos/mapSize);
	vec4 shadow = Texel(shadowMap, texture_coords);
    return Texel(texture, texture_coords)*color*(air.r < 0.5 ? light : (light + shadow)*0.5);
}
