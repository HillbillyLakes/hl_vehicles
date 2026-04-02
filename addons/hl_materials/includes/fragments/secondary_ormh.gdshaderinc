if ((secondary_ao_enabled || secondary_roughness_enabled
			|| secondary_metallic_enabled || secondary_height_enabled)
		&& secondary_texture_enabled) {

	vec4 secondary_ormh = vec4(1.0, 1.0, 1.0, 1.0);
	
	if (!secondary_texture_triplanar && !secondary_use_nearest) {
		secondary_ormh = texture(secondary_ormh_texture, (UV * secondary_texture_scale) + secondary_texture_offset.xy).rgba;
	} else if (!secondary_texture_triplanar && secondary_use_nearest) {
		secondary_ormh = texture(secondary_ormh_texture_nearest, (UV * secondary_texture_scale) + secondary_texture_offset.xy).rgba;
	} else if (secondary_texture_triplanar && !secondary_use_nearest) {
		secondary_ormh = triplanar_texture_rotated(
			secondary_ormh_texture,
			uv2_power_normal,
			(uv2_triplanar_pos * secondary_texture_scale) + secondary_texture_offset,
			secondary_texture_rotation
		).rgba;
	} else {
		secondary_ormh = triplanar_texture_nearest_rotated(
			secondary_ormh_texture_nearest,
			uv2_power_normal,
			(uv2_triplanar_pos * secondary_texture_scale) + secondary_texture_offset,
			secondary_texture_rotation
		).rgba;
	}

	AO = mix(AO, secondary_ormh.r, secondary_ao_enabled ? secondary_ao_strength : 0.0);
	ROUGHNESS = mix(ROUGHNESS, secondary_ormh.g, secondary_roughness_enabled ? secondary_roughness_strength : 0.0);
	METALLIC = mix(METALLIC, secondary_ormh.b, secondary_metallic_enabled ? secondary_metallic_strength : 0.0);
	NORMAL_MAP_DEPTH = mix(NORMAL_MAP_DEPTH, secondary_ormh.a, secondary_height_enabled ? 1.0 - secondary_height_strength : 0.0);
}