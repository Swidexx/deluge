extern Image airMask;
extern Image lightMap;
extern Image lightMapBlur;
extern vec2 camPos;
extern vec2 scale;
extern vec2 mapSize;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	vec4 air = Texel(airMask, screen_coords/love_ScreenSize.xy*scale + camPos/mapSize);
    vec4 light = Texel(lightMap, screen_coords/love_ScreenSize.xy);
	vec4 lightBlur = Texel(lightMapBlur, screen_coords/love_ScreenSize.xy);
	return Texel(texture, screen_coords/love_ScreenSize.xy)*color*(air.r > 0.5 ? light : lightBlur*2.0);
}
