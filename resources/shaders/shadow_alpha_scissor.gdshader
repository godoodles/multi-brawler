shader_type spatial;
render_mode unshaded;

uniform sampler2D texture_albedo;
uniform sampler2D noise;
uniform vec2 noise_speed = vec2(0.05, 0.025);


void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	float noise_tex_1 = texture(noise, vec2(0.66)+UV+TIME*noise_speed).r;
	float noise_tex_2 = texture(noise, UV-TIME*noise_speed*0.1).g;
	float noise_tex_3 = texture(noise, vec2(0.33)+UV+TIME*noise_speed*0.3).b;
	float noise_combined = (noise_tex_1 + noise_tex_2 + noise_tex_3)/3.0;
	ALBEDO = vec3(0.0);
	ALPHA = smoothstep(0.95, 0.99, abs(1.0-albedo_tex.g)+noise_combined);
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
