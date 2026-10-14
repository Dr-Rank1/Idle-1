shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;

uniform float progress : hint_range(0.0, 1.0) = 0.75;
uniform vec4 bg_color : source_color = vec4(0.12, 0.15, 0.20, 0.72);
uniform vec4 fill_color : source_color = vec4(1.0, 0.88, 0.12, 1.0);
uniform float inner_radius : hint_range(0.1, 0.5) = 0.24;
uniform float outer_radius : hint_range(0.1, 0.5) = 0.48;

void vertex() {
	// Full camera billboard preserving vertex positions and mesh size
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		vec4(normalize(INV_VIEW_MATRIX[0].xyz), 0.0),
		vec4(normalize(INV_VIEW_MATRIX[1].xyz), 0.0),
		vec4(normalize(INV_VIEW_MATRIX[2].xyz), 0.0),
		MODEL_MATRIX[3]
	);
}

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	
	// Sharp clean circular ring with subtle antialiasing
	float edge = fwidth(dist);
	float mask = smoothstep(inner_radius - edge, inner_radius, dist) *
	             (1.0 - smoothstep(outer_radius, outer_radius + edge, dist));
	
	if (mask <= 0.05) {
		discard;
	}
	
	// Angle from top (12 o'clock) clockwise
	float angle = atan(uv.x, -uv.y);
	if (angle < 0.0) {
		angle += 6.28318530718;
	}
	float frac = angle / 6.28318530718;
	
	vec4 col = (frac <= progress) ? fill_color : bg_color;
	ALBEDO = col.rgb;
	ALPHA = col.a * mask;
}
