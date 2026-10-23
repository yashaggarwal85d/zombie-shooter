// Look-test figures: a dark body with two rims. The pod's cold light edges the
// side facing the cabin, fading with distance; the sky's key light edges the
// top and the side facing the moon or sun. COLOR is the per-figure tint from
// ToyActorLayer (warm during a wind-up, white on a hit), applied to the rims
// only. Works on Mobile and Compatibility.
shader_type canvas_item;
render_mode unshaded;

uniform vec4 body_color : source_color = vec4(0.012, 0.016, 0.024, 1.0);
uniform vec4 key_color : source_color = vec4(0.49, 0.55, 0.65, 1.0);
uniform vec4 pod_color : source_color = vec4(0.75, 0.94, 1.0, 1.0);
uniform float pod_strength = 1.0;
// The pod's window and the orb, in screen UV (0..1, top left origin).
uniform vec2 pod_uv = vec2(0.5, 0.8);
uniform float key_side = 1.0;
// How far the pod's light reaches, as a share of screen width.
uniform float pod_reach = 0.35;
uniform float rim_px = 28.0;

void fragment() {
	float a = texture(TEXTURE, UV).a;
	vec2 px = TEXTURE_PIXEL_SIZE * rim_px;
	// +1 when UV.x grows to the right on screen, -1 when the figure is flipped.
	float flip = dFdx(UV.x) >= 0.0 ? 1.0 : -1.0;
	float pod_side = SCREEN_UV.x < pod_uv.x ? 1.0 : -1.0;
	float pod_edge = clamp(a - texture(TEXTURE, UV + vec2(px.x * pod_side * flip, 0.0)).a, 0.0, 1.0);
	float key_edge = clamp(a - texture(TEXTURE, UV + vec2(px.x * 0.6 * key_side * flip, 0.0)).a, 0.0, 1.0);
	float top_edge = clamp(a - texture(TEXTURE, UV - vec2(0.0, px.y * 0.7)).a, 0.0, 1.0);
	float d = abs(SCREEN_UV.x - pod_uv.x) / pod_reach;
	float pod = pod_strength * clamp(1.15 - d, 0.0, 1.0);
	vec3 rim = key_color.rgb * max(top_edge * 0.75, key_edge * 0.55);
	rim = max(rim, pod_color.rgb * pod_edge * pod);
	// Nothing is fully unlit: a faint key edge everywhere keeps far figures readable.
	rim = max(rim, key_color.rgb * pod_edge * 0.35);
	// The player keeps a thin cold outline all round, so they read even in
	// front of the dark cabin. Look-test shortcut: ToyActorLayer tints only
	// the player green-white, so a green lead in the tint marks the player.
	float is_player = clamp((COLOR.g - COLOR.r) * 6.0, 0.0, 1.0);
	float ring = 0.0;
	vec2 o = TEXTURE_PIXEL_SIZE * 7.0;
	ring = max(ring, a - texture(TEXTURE, UV + vec2(o.x, 0.0)).a);
	ring = max(ring, a - texture(TEXTURE, UV - vec2(o.x, 0.0)).a);
	ring = max(ring, a - texture(TEXTURE, UV + vec2(0.0, o.y)).a);
	ring = max(ring, a - texture(TEXTURE, UV - vec2(0.0, o.y)).a);
	rim = max(rim, pod_color.rgb * clamp(ring, 0.0, 1.0) * 0.7 * is_player);
	vec3 c = body_color.rgb + rim * COLOR.rgb;
	COLOR = vec4(c, a * COLOR.a);
}
