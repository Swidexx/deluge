extern float time;

float rand(vec2 n)
{
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

//(n1x, n1y, n2x, n2y) n=closest points
vec4 voronoi(vec2 pos, float jitter)
{
	vec2 posi = floor(pos);
	vec2 pos2 = vec2(0, 0);
	float dist = 0.0;
	vec2 n1 = vec2(0, 0);
	vec2 n2 = vec2(0, 0);
	float n1d = 9.0;
	float n2d = 9.0;
	for (int i=-2; i < 2; i++) {
		for (int j=-2; j < 2; j++) {
			pos2 = posi+vec2(i,j)+vec2(0.5)+(vec2(rand(posi+vec2(i,j)), rand(posi+vec2(i,j)+0.5))*2.0-1.0)*jitter*0.5;
			dist = dot(pos-pos2, pos-pos2);
			if (dist < n2d) {
				if (dist < n1d) {
					n2d = n1d;
					n1d = dist;
					n2 = n1;
					n1 = pos2;
				} else {
					n2d = dist;
					n2 = pos2;
				}
			}
		}
	}
	return vec4(n1, n2);
}

vec4 voronoi(vec2 pos)
{
	return voronoi(pos, 1.0);
}

vec4 mod289(vec4 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x)
{
    return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
    return 1.79284291400159 - 0.85373472095314 * r;
}

vec2 fade(vec2 t) {
    return t*t*t*(t*(t*6.0-15.0)+10.0);
}

float cnoise(vec2 P)
{
    vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
    vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
    Pi = mod289(Pi);
    vec4 ix = Pi.xzxz;
    vec4 iy = Pi.yyww;
    vec4 fx = Pf.xzxz;
    vec4 fy = Pf.yyww;

    vec4 i = permute(permute(ix) + iy);

    vec4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
    vec4 gy = abs(gx) - 0.5 ;
    vec4 tx = floor(gx + 0.5);
    gx = gx - tx;

    vec2 g00 = vec2(gx.x,gy.x);
    vec2 g10 = vec2(gx.y,gy.y);
    vec2 g01 = vec2(gx.z,gy.z);
    vec2 g11 = vec2(gx.w,gy.w);

    vec4 norm = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
    g00 *= norm.x;
    g01 *= norm.y;
    g10 *= norm.z;
    g11 *= norm.w;

    float n00 = dot(g00, vec2(fx.x, fy.x));
    float n10 = dot(g10, vec2(fx.y, fy.y));
    float n01 = dot(g01, vec2(fx.z, fy.z));
    float n11 = dot(g11, vec2(fx.w, fy.w));

    vec2 fade_xy = fade(Pf.xy);
    vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	vec4 pixel = Texel(texture, texture_coords);
	vec2 uv = (screen_coords-love_ScreenSize.xy/2.0)/min(love_ScreenSize.x, love_ScreenSize.y);
	float n = min(cnoise(uv*12 + vec2(-sin(time*0.5)*8.0, cos(time)*2.0))*0.5 + 0.7, 1.0);
	n *= mod(cnoise(uv*24 + vec2(sin(time*0.5)*4.0, -sin(time)*4.0)), 1.0)*1.0/6.0 + 5.0/6.0;
	n *= rand(uv + time)*1.0/4.0 + 3.0/4.0;
	pixel.r += n;
	pixel.r *= 0.5;
	float gs = -pow((time - 5.0/2.0)*2.0/5.0, 2.0) + 1.0;
	pixel.rgb *= gs;
	return pixel;
}
