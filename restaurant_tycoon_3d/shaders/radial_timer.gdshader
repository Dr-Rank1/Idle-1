shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 bg_color : source_color = vec4(1.0, 1.0, 1.0, 0.85);
uniform vec4 fill_color : source_color = vec4(0.28, 0.82, 0.38, 1.0);
uniform float inner_radius : hint_range(0.1, 0.5) = 0.30;
uniform float outer_radius : hint_range(0.1, 0.5) = 0.44;

void vertex() {
	// Billboard facing camera
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		INV_VIEW_MATRIX[0],
		INV_VIEW_MATRIX[1],
		INV_VIEW_MATRIX[2],
		MODEL_MATRIX[3]
	);
}

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	
	// Soft antialiased edges
	float edge_width = fwidth(dist);
	float mask = smoothstep(inner_radius - edge_width, inner_radius, dist) *
	             (1.0 - smoothstep(outer_radius, outer_radius + edge_width, dist));
	
	if (mask <= 0.01) {
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
