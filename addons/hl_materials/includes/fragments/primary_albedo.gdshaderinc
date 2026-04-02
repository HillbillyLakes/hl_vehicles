if (albedo_enabled) {

	if (albedo_use_nearest) {
		vec4 albedo = triplanar_enabled ? triplanar_texture_nearest(albedo_texture_nearest, uv1_power_normal, uv1_triplanar_pos).rgba : texture(albedo_texture_nearest, texture_uv).rgba;
		ALBEDO = albedo.rgb * albedo_color;
		ALPHA = alpha_enabled ? albedo.a : 1.0;
	} else {
		vec4 albedo = triplanar_enabled ? triplanar_texture(albedo_texture, uv1_power_normal, uv1_triplanar_pos).rgba : texture(albedo_texture, texture_uv).rgba;
		ALBEDO = albedo.rgb * albedo_color;
		ALPHA = alpha_enabled ? albedo.a : 1.0;
		
	}
	
	if (UV.y < texture_trim_top) {
		ALPHA = 0.0;
	}

   	ALPHA_SCISSOR_THRESHOLD = alpha_enabled ? alpha_threshold : 0.0;
}