extern float radius = 1.0;
extern vec2 dir;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 sum = vec4(0.0);
    vec2 tc = texture_coords;
    vec2 blur = vec2(radius)/love_ScreenSize.xy;
	//clamping necessary?
	sum += Texel(texture, min(max(vec2(tc.x - 4.0*blur.x*dir.x, tc.y - 4.0*blur.y*dir.y), vec2(0.0)), vec2(1.0))) * 0.0162162162;
    sum += Texel(texture, min(max(vec2(tc.x - 3.0*blur.x*dir.x, tc.y - 3.0*blur.y*dir.y), vec2(0.0)), vec2(1.0))) * 0.0540540541;
    sum += Texel(texture, min(max(vec2(tc.x - 2.0*blur.x*dir.x, tc.y - 2.0*blur.y*dir.y), vec2(0.0)), vec2(1.0))) * 0.1216216216;
    sum += Texel(texture, min(max(vec2(tc.x - 1.0*blur.x*dir.x, tc.y - 1.0*blur.y*dir.y), vec2(0.0)), vec2(1.0))) * 0.1945945946;

    sum += Texel(texture, tc) * 0.2270270270;

    sum += Texel(texture, min(max(vec2(tc.x + 1.0*blur.x*dir.x, tc.y + 1.0*blur.y*dir.y), vec2(0.0)), vec2(1.0))) * 0.1945945946;
    sum += Texel(texture, min(max(vec2(tc.x + 2.0*blur.x*dir.x, tc.y + 2.0*blur.y*dir.y), vec2(0.0)), vec2(1.0))) * 0.1216216216;
    sum += Texel(texture, min(max(vec2(tc.x + 3.0*blur.x*dir.x, tc.y + 3.0*blur.y*dir.y), vec2(0.0)), vec2(1.0))) * 0.0540540541;
    sum += Texel(texture, min(max(vec2(tc.x + 4.0*blur.x*dir.x, tc.y + 4.0*blur.y*dir.y), vec2(0.0)), vec2(1.0))) * 0.0162162162;

    return vec4(sum.rgb, 1.0) * color;
}
