class_name StageCShaders
extends RefCounted
## EXPERIMENT (Stage C, C2/C3). Shader sources kept in one place. All of them
## stick to features the Compatibility and Mobile renderers both support.

## Black silhouette with a thin rim on the side facing the light (the front,
## which faces the chamber or the player). Unshaded so the rim stays readable
## in the dark (readability rule 1, Stage B section 3).
const RIM: String = """
shader_type canvas_item;
render_mode unshaded;
uniform vec4 body_color : source_color = vec4(0.015, 0.016, 0.022, 1.0);
uniform vec4 rim_color : source_color = vec4(0.72, 0.86, 1.0, 1.0);
uniform vec4 top_rim_color : source_color = vec4(0.35, 0.38, 0.45, 1.0);
uniform float rim_px = 6.0;
uniform float rim_strength = 1.0;
void fragment() {
	float a = texture(TEXTURE, UV).a;
	vec2 px = TEXTURE_PIXEL_SIZE * rim_px;
	float front = clamp(a - texture(TEXTURE, UV + vec2(px.x, 0.0)).a, 0.0, 1.0);
	float top = clamp(a - texture(TEXTURE, UV - vec2(0.0, px.y)).a, 0.0, 1.0);
	vec3 c = body_color.rgb;
	c = mix(c, top_rim_color.rgb, top * 0.8 * rim_strength);
	c = mix(c, rim_color.rgb, front * rim_strength);
	COLOR = vec4(c, a * COLOR.a);
}
"""

## Drifting fbm fog. Octaves drop on the low preset.
const FOG: String = """
shader_type canvas_item;
render_mode unshaded;
uniform vec4 fog_color : source_color = vec4(0.42, 0.48, 0.58, 1.0);
uniform float density = 0.4;
uniform int octaves = 5;
uniform vec2 drift = vec2(0.02, 0.004);
uniform float scale = 3.0;
uniform float bottom_weight = 0.6;
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float fbm(vec2 p) {
	float v = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 8; i++) {
		if (i >= octaves) { break; }
		v += amp * vnoise(p);
		p *= 2.03;
		amp *= 0.5;
	}
	return v;
}
void fragment() {
	vec2 uv = UV * vec2(scale * 1.78, scale);
	float n = fbm(uv + TIME * drift * 10.0);
	float m = fbm(uv * 0.45 - TIME * drift * 4.0 + 7.3);
	float f = smoothstep(0.25, 0.85, n * 0.6 + m * 0.6);
	float h = mix(1.0 - bottom_weight, 1.0, UV.y);
	COLOR = vec4(fog_color.rgb, f * density * h);
}
"""

## Full-screen pass: film grain, vignette, and the greyscale readability check.
const POST: String = """
shader_type canvas_item;
render_mode unshaded;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform float grain = 0.045;
uniform float vignette = 0.45;
uniform bool greyscale = false;
void fragment() {
	vec3 c = texture(screen_tex, SCREEN_UV).rgb;
	float n = fract(sin(dot(floor(FRAGCOORD.xy) + floor(TIME * 24.0) * 17.0, vec2(12.9898, 78.233))) * 43758.5453);
	c += (n - 0.5) * grain;
	vec2 d = SCREEN_UV - 0.5;
	c *= 1.0 - vignette * dot(d, d) * 1.6;
	if (greyscale) {
		c = vec3(dot(c, vec3(0.2126, 0.7152, 0.0722)));
	}
	COLOR = vec4(c, 1.0);
}
"""

## The chamber's glass: cold white-blue, brightest thing on screen (rule 2),
## with slow frost bands and a hint of the figure inside.
const CHAMBER_GLASS: String = """
shader_type canvas_item;
render_mode unshaded;
uniform vec4 glass_color : source_color = vec4(0.78, 0.9, 1.0, 1.0);
uniform vec4 core_color : source_color = vec4(0.95, 0.98, 1.0, 1.0);
uniform float pulse = 0.0;
void fragment() {
	vec2 uv = UV;
	float edge = smoothstep(0.0, 0.18, uv.x) * smoothstep(0.0, 0.18, 1.0 - uv.x);
	float frost = 0.5 + 0.5 * sin(uv.y * 40.0 + sin(uv.x * 9.0 + TIME * 0.6) * 2.0 + TIME * 0.4);
	float glow = mix(0.55, 1.0, edge) * mix(0.9, 1.0, frost) * (0.92 + 0.08 * pulse);
	vec3 c = mix(glass_color.rgb, core_color.rgb, edge * 0.7) * glow;
	COLOR = vec4(c, COLOR.a);
}
"""


static func material(code: String) -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = code
	var m: ShaderMaterial = ShaderMaterial.new()
	m.shader = shader
	return m
