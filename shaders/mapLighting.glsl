extern Image airMask;
extern Image lightMap;
extern Image bakedLightMap;
extern Image bakedLightMapBlur;
extern vec2 camPos;
extern vec2 viewScale;
extern vec2 mapSize;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	vec4 air = Texel(airMask, texture_coords*viewScale + camPos/mapSize);
	vec4 light = Texel(lightMap, texture_coords);
    vec4 bakedLight = Texel(bakedLightMap, texture_coords*viewScale + camPos/mapSize);
	vec4 bakedLightBlur = Texel(bakedLightMapBlur, texture_coords*viewScale + camPos/mapSize);
	return Texel(texture, texture_coords)*color*(air.r > 0.5 ? max(light, bakedLight) : min(bakedLightBlur*2.0, vec4(1.0)));
}
