if (triplanar_enabled) {
	mat3 triplanar = calculate_triplanar_normal(NORMAL, VERTEX);
	uv1_power_normal = triplanar[0];
	uv1_triplanar_pos = triplanar[1];
}