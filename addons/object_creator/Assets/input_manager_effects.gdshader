shader_type canvas_item;
//render_mode blend_add;

uniform vec4 error_color : source_color;
uniform bool active;
uniform float opacity: hint_range(0.0, 1.0, 0.01) = 0.4;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (active) {
		vec4 new_color = error_color * opacity;
		new_color += COLOR * (1. - opacity);
		COLOR = new_color;
	}
}
