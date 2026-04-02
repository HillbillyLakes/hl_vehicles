if (secondary_texture_enabled) {
	mat3 triplanar = calculate_triplanar_normal(NORMAL, VERTEX);
	uv2_power_normal = triplanar[0];
	uv2_triplanar_pos = triplanar[1];
}