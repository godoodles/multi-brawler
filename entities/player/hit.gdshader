shader_type canvas_item;

uniform float ttl : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D curve;

void fragment() {
	vec4 color = vec4(1.0, 0.0, 0.0, texture(curve, vec2(ttl, 0.0)).r * pow(distance(UV, vec2(0.5, 0.5)), 3.0));
	COLOR = color;
}
