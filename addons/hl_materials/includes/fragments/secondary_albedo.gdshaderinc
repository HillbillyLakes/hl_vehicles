if (secondary_albedo_enabled && secondary_texture_enabled) {
	if (!secondary_texture_triplanar && !secondary_use_nearest) {
		vec4 secondary_albedo = texture(secondary_albedo_texture, (UV * secondary_texture_scale) + secondary_texture_offset.xy).rgba;
		ALBEDO = mix(ALBEDO, secondary_albedo.rgb * secondary_albedo_color, secondary_albedo_strength * secondary_albedo.a);
	} else if (!secondary_texture_triplanar && secondary_use_nearest) {
		vec4 secondary_albedo = texture(secondary_albedo_texture_nearest, (UV * secondary_texture_scale) + secondary_texture_offset.xy).rgba;
		ALBEDO = mix(ALBEDO, secondary_albedo.rgb * secondary_albedo_color, secondary_albedo_strength * secondary_albedo.a);
	} else if (secondary_texture_triplanar && secondary_use_nearest) {
		vec4 secondary_albedo = triplanar_texture_nearest_rotated(secondary_albedo_texture_nearest, uv2_power_normal, (uv2_triplanar_pos * secondary_texture_scale) + secondary_texture_offset, secondary_texture_rotation).rgba;
		ALBEDO = mix(ALBEDO, secondary_albedo.rgb * secondary_albedo_color, secondary_albedo_strength * secondary_albedo.a);
	} else {
		vec4 secondary_albedo = triplanar_texture_rotated(secondary_albedo_texture, uv2_power_normal, (uv2_triplanar_pos * secondary_texture_scale) + secondary_texture_offset, secondary_texture_rotation).rgba;
		ALBEDO = mix(ALBEDO, secondary_albedo.rgb * secondary_albedo_color, secondary_albedo_strength * secondary_albedo.a);
	}
}