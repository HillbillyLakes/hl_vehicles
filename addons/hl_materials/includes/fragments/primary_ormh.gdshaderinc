if (roughness_enabled || normal_enabled || ao_enabled || metallic_enabled) {
	vec4 ormh = calculate_ormh(UV, texture_uv_scale, triplanar_enabled, uv1_power_normal, uv1_triplanar_pos);
	AO = ormh.r;
	ROUGHNESS = ormh.g;
	METALLIC = ormh.b;
	NORMAL_MAP_DEPTH = ormh.a;
}