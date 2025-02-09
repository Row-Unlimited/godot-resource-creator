shader_type canvas_item;

uniform bool active;
uniform vec4 color_override : source_color = vec4(1.0);
uniform bool override_color;

void fragment() {
	if (override_color) {
		COLOR.rgb = color_override.rgb;
	}
	if (active) {
		if ((COLOR.r + COLOR.g + COLOR.b) / 3. > 0.5) {
			COLOR.rgb *= 0.7;
		}
		else {
			COLOR.rgb = vec3(max(COLOR.r, 0.1), max(COLOR.g, 0.1), max(COLOR.b, 0.1));
			COLOR.rgb *= 2.;
		}
	}
}

