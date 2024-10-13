shader_type canvas_item;

uniform bool active;

void fragment() {
	if (active) {
		if ((COLOR.r + COLOR.g + COLOR.b) / 3. > 0.5) {
			COLOR.rgb *= 0.7;
		}
		else {
			COLOR.rgb *= 1.3;
		}
	}
}
