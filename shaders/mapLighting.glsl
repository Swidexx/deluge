extern Image airMask;
extern Image lightMap;
extern Image bakedLightMap;
extern Image bakedLightMapBlur;
extern vec2 camPos;
extern vec2 scale;
extern vec2 mapSize;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	vec4 air = Texel(airMask, screen_coords/love_ScreenSize.xy*scale + camPos/mapSize);
	vec4 light = Texel(lightMap, screen_coords/love_ScreenSize.xy);
    vec4 bakedLight = Texel(bakedLightMap, screen_coords/love_ScreenSize.xy*scale + camPos/mapSize);
	vec4 bakedLightBlur = Texel(bakedLightMapBlur, screen_coords/love_ScreenSize.xy*scale + camPos/mapSize);
	return Texel(texture, screen_coords/love_ScreenSize.xy)*color*(air.r > 0.5 ? max(light, bakedLight) : min(bakedLightBlur*2.0, vec4(1.0)));
}
