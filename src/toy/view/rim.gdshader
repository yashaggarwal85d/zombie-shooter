// Black silhouette with a thin rim on the side facing the light (Stage C C2,
// readability rule 1). Unshaded so rims stay readable in the dark. Works on
// the Mobile and Compatibility renderers.
shader_type canvas_item;
render_mode unshaded;
uniform vec4 body_color : source_color = vec4(0.015, 0.016, 0.022, 1.0);
uniform vec4 rim_color : source_color = vec4(0.72, 0.86, 1.0, 1.0);
uniform vec4 top_rim_color : source_color = vec4(0.35, 0.38, 0.45, 1.0);
uniform float rim_px = 24.0;
void fragment() {
	float a = texture(TEXTURE, UV).a;
	vec2 px = TEXTURE_PIXEL_SIZE * rim_px;
	float front = clamp(a - texture(TEXTURE, UV + vec2(px.x, 0.0)).a, 0.0, 1.0);
	float top = clamp(a - texture(TEXTURE, UV - vec2(0.0, px.y)).a, 0.0, 1.0);
	vec3 c = body_color.rgb;
	c = mix(c, top_rim_color.rgb, top * 0.8);
	// COLOR carries a per-draw tint: white rim normally, warmer when hurt.
	c = mix(c, rim_color.rgb * COLOR.rgb, front);
	COLOR = vec4(c, a * COLOR.a);
}
