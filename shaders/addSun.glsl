extern Image sunLightMap;
extern vec2 camPos;
extern vec2 scale;
extern vec2 mapSize;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	vec4 sun = Texel(sunLightMap, screen_coords/love_ScreenSize.xy*scale + camPos/mapSize);
	vec4 dynamic = Texel(texture, screen_coords/love_ScreenSize.xy);
	return max(sun, dynamic);
}
