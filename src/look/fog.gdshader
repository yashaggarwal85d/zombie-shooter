// Drifting valley mist for the look test. Thickest at the bottom of the rect,
// fading upward, broken up by slow noise, and lit from inside by the pod's
// window so the cold light reads as a glow in the air. With detail = 0 it is a
// plain gradient (the low quality preset). Works on Mobile and Compatibility.
shader_type canvas_item;
render_mode blend_mix;

uniform vec4 fog_color : source_color = vec4(0.35, 0.42, 0.53, 0.5);
uniform float density = 1.0;
// 0..1: share of the rect (from the bottom) that is solid before it fades.
uniform float floor_share = 0.15;
uniform float detail = 1.0;
uniform float drift = 8.0;
uniform float noise_scale = 0.004;
uniform float seed = 0.0;
uniform vec2 light_pos = vec2(1100.0, -110.0);
uniform vec4 light_color : source_color = vec4(0.75, 0.94, 1.0, 1.0);
uniform float light_radius = 420.0;
uniform float light_strength = 0.0;

varying vec2 world;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * noise(p);
		p = p * 2.03 + vec2(17.1, 9.2);
		a *= 0.5;
	}
	return v;
}

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	// UV.y is 0 at the top of the rect, 1 at the bottom.
	float h = 1.0 - UV.y;
	float body = 1.0 - smoothstep(floor_share, 1.0, h);
	float n = 1.0;
	if (detail > 0.0) {
		vec2 p = world * noise_scale + vec2(TIME * drift * noise_scale + seed, seed * 0.37);
		n = mix(1.0, 0.35 + 1.1 * fbm(p * vec2(0.6, 1.6)), detail);
	}
	float a = clamp(fog_color.a * density * body * n, 0.0, 1.0);
	vec3 c = fog_color.rgb;
	float d = length(world - light_pos) / light_radius;
	float glow = light_strength * exp(-d * d * 2.2);
	c = mix(c, light_color.rgb, clamp(glow, 0.0, 1.0));
	a = clamp(a + glow * 0.35 * body, 0.0, 1.0);
	COLOR = vec4(c, a);
}
