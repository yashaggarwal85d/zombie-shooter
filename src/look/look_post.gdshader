// Whole-screen grade for the look test: lifts the shadows toward the time of
// day's shadow colour, adds a soft vignette and fine film grain. The grain is
// off on the low preset. The HUD sits on a layer above and is not graded.
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen : hint_screen_texture, filter_linear;
uniform vec4 shadow_tint : source_color = vec4(0.024, 0.035, 0.078, 1.0);
uniform float lift = 0.6;
uniform float vignette = 0.5;
uniform float grain = 0.035;

float hash(vec2 p) {
	p = fract(p * vec2(443.897, 441.423));
	p += dot(p, p.yx + 19.19);
	return fract((p.x + p.y) * p.x);
}

void fragment() {
	vec3 c = texture(screen, SCREEN_UV).rgb;
	float lum = dot(c, vec3(0.299, 0.587, 0.114));
	// Lift: darkest values move toward the tint, highlights are untouched.
	c = mix(c, max(c, shadow_tint.rgb), lift * (1.0 - smoothstep(0.0, 0.25, lum)));
	vec2 v = SCREEN_UV - 0.5;
	v.x *= 1.4;
	c *= 1.0 - vignette * smoothstep(0.35, 0.95, length(v));
	if (grain > 0.0) {
		float g = hash(SCREEN_UV * 1000.0 + fract(TIME * 7.13)) - 0.5;
		c += g * grain;
	}
	COLOR = vec4(c, 1.0);
}
