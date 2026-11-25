shader_type canvas_item;

const int SIDES = 20;
uniform bool occlude = false;
uniform vec2 lid_outline[SIDES];

void fragment() {
	if (occlude) {
		bool positive = false;
		bool negative = false;
		for (int index = 0; index < SIDES; index++) {
			vec2 start = lid_outline[index];
			vec2 edge = lid_outline[(index + 1) % SIDES] - start;
			vec2 point = SCREEN_UV - start;
			float side = edge.x * point.y - edge.y * point.x;
			positive = positive || side > 0.0;
			negative = negative || side < 0.0;
			if (positive && negative) { break; }
		}
		if (!(positive && negative)) { discard; }
	}
}
