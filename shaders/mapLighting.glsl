extern Image lightMap;
extern Image airMask;
extern vec2 camPos;
extern vec2 scale;
extern vec2 mapSize;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 light = Texel(lightMap, texture_coords*scale + camPos/mapSize);
    vec4 air = Texel(airMask, texture_coords*scale + camPos/mapSize);
    return Texel(texture, texture_coords)*color*(air.r < 0.5 ? light : vec4(1.0));
}
