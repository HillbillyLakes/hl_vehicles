group_uniforms Triplanar;

	varying vec3 uv1_triplanar_pos;
	varying vec3 uv1_power_normal;
	varying vec3 uv2_triplanar_pos;
	varying vec3 uv2_power_normal;

	uniform bool triplanar_enabled = false;


	uniform float uv1_blend_sharpness: hint_range(0.0, 150.0, 0.001) = 100.0;
	uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
	uniform vec3 uv1_offset;
	uniform vec3 uv2_scale = vec3(1.0, 1.0, 1.0);
	uniform vec3 uv2_offset;
group_uniforms;

mat3 calculate_triplanar_normal(vec3 normal, vec3 vpos) {
	vec3 strength = pow(abs(normal), vec3(uv1_blend_sharpness));
	strength /= dot(strength, vec3(1.0));
	vec3 position = vpos * uv1_scale + uv1_offset;
	position *= vec3(1.0, -1.0, 1.0);
	return mat3(strength, position, vec3(0.0, 0.0, 0.0));
	//return mat3(vec3(0.0, 0.0, 0.0), vec3(0.0, 0.0, 0.0), vec3(0.0, 0.0, 0.0));
}