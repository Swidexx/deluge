extern Image other;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 pixA = Texel(texture, screen_coords/love_ScreenSize.xy);
	vec4 pixB = Texel(other, screen_coords/love_ScreenSize.xy);
	return max(pixA, pixB);
}
