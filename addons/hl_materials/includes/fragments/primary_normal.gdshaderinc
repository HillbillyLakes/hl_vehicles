if (normal_enabled) {
	vec4 normal = calculate_normal(UV, texture_uv_scale, triplanar_enabled, uv1_power_normal, uv1_triplanar_pos);
	NORMAL_MAP = normal.rgb;
	//NORMAL_MAP_DEPTH = 1.0;
}

if (force_front_normals) {
	NORMAL = !FRONT_FACING ? -NORMAL : NORMAL;
}