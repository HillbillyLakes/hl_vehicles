vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)) * p_weights.x;
	return samp;
}

vec4 triplanar_texture_nearest(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)) * p_weights.x;
	return samp;
}

vec4 triplanar_texture_rotated(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos, float p_angle) {
	mat2 rotation = mat2(1.0);
	if (p_angle != 0.0) {
		float angle = radians(p_angle);
		rotation = mat2(vec2(sin(angle), -cos(angle)), vec2(cos(angle), sin(angle)));
	}
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy * rotation) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz * rotation) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0) * rotation) * p_weights.x;
	return samp;
}

vec4 triplanar_texture_nearest_rotated(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos, float p_angle) {
	mat2 rotation = mat2(1.0);
	if (p_angle != 0.0) {
		float angle = radians(p_angle);
		rotation = mat2(vec2(sin(angle), -cos(angle)), vec2(cos(angle), sin(angle)));
	}
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy * rotation) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz * rotation) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0) * rotation) * p_weights.x;
	return samp;
}

vec4 triplanar_texture_normal(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)) * p_weights.x;
	return samp;
}