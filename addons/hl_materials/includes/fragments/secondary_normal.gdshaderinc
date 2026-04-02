
if (secondary_normal_enabled && secondary_texture_enabled) {

	//vec4 normal = calculate_secondary_normal(UV, secondary_texture_scale, triplanar_enabled, uv2_power_normal, (uv2_triplanar_pos * secondary_texture_scale) + secondary_texture_offset);


	vec4 secondary_normal = vec4(1.0, 1.0, 1.0, 1.0);
	
	if (!secondary_texture_triplanar && !secondary_use_nearest) {
		secondary_normal = texture(secondary_normal_texture, (UV * secondary_texture_scale) + secondary_texture_offset.xy).rgba;
	} else if (!secondary_texture_triplanar && secondary_use_nearest) {
		secondary_normal = texture(secondary_normal_texture_nearest, (UV * secondary_texture_scale) + secondary_texture_offset.xy).rgba;
	} else if (secondary_texture_triplanar && !secondary_use_nearest) {
		secondary_normal = triplanar_texture_rotated(
			secondary_normal_texture,
			uv2_power_normal,
			(uv2_triplanar_pos * secondary_texture_scale) + secondary_texture_offset,
			secondary_texture_rotation
		).rgba;
	} else {
		secondary_normal = triplanar_texture_nearest_rotated(
			secondary_normal_texture_nearest,
			uv2_power_normal,
			(uv2_triplanar_pos * secondary_texture_scale) + secondary_texture_offset,
			secondary_texture_rotation
		).rgba;
	}



	//NORMAL_MAP = normal.rgb;
	//vec3 secondary_normal = triplanar_texture_rotated(
		//secondary_normal_texture,
		//uv2_power_normal,
		//uv2_triplanar_pos * secondary_texture_scale,
		//secondary_texture_rotation
	//).rgb;

	NORMAL_MAP = mix(
		NORMAL_MAP,
		secondary_normal.rgb,
		secondary_normal_blend_amount
	);
	
	if (secondary_normal_add_amount != 0.0) {
		NORMAL_MAP.r = clamp(NORMAL_MAP.r + (secondary_normal.r * secondary_normal_add_amount), 0.0, 1.0);
		NORMAL_MAP.g = clamp(NORMAL_MAP.g + (secondary_normal.g * secondary_normal_add_amount), 0.0, 1.0);
		NORMAL_MAP.b = clamp(NORMAL_MAP.b + (secondary_normal.b * secondary_normal_add_amount), 0.0, 1.0);
	}

	NORMAL_MAP_DEPTH = mix(
		NORMAL_MAP_DEPTH,
		NORMAL_MAP_DEPTH * secondary_normal_strength,
		secondary_normal_blend_amount
	);
}