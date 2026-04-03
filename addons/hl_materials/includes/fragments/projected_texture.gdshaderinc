if (projected_texture_enabled) {

	if ((projected_layer_angle_to_up) < projected_layer_max_angle) {

		float blend_ratio = (1.0 - ((projected_layer_angle_to_up) / projected_layer_max_angle));

		vec4 pl_albedo_read = triplanar_enabled ?
			(projected_use_nearest ? (
				triplanar_texture_nearest(projected_albedo_texture_nearest, uv1_power_normal, uv1_triplanar_pos * projected_texture_scale).rgba
			) : (
				triplanar_texture(projected_albedo_texture, uv1_power_normal, uv1_triplanar_pos * projected_texture_scale).rgba
			))
			:
			(projected_use_nearest ? (
				texture(projected_albedo_texture_nearest, UV * projected_texture_scale).rgba
			) : (
				texture(projected_albedo_texture, UV * projected_texture_scale).rgba
			));

		float noise = 0.0;
		if (projected_noise_amount > 0.0) {
			vec4 pl_noise_read = triplanar_enabled ?
				triplanar_texture(projected_noise_texture, uv1_power_normal, (uv1_triplanar_pos * projected_texture_scale)).rgba
				: texture(projected_noise_texture, UV * projected_texture_scale ).rgba;
			// projected_noise_triplanar
			//vec4 pl_noise_read = texture(projected_noise_texture, (UV + NODE_POSITION_WORLD.xy ) * projected_texture_scale).rgba;

			noise = pl_noise_read.r * projected_noise_amount;
		}

		float _blend_ratio = (1.0 * blend_ratio * projected_thickness) - noise;
		
		if (pl_albedo_read.a > alpha_threshold) {
			
			ALBEDO = mix(
				ALBEDO,
				pl_albedo_read.rgb * projected_albedo_color,
				projected_albedo_enabled ? clamp(_blend_ratio, 0.0, 1.0) : 0.0
			);

			if (projected_roughness_enabled || projected_ao_enabled || projected_metallic_enabled || projected_height_enabled) {
				vec4 ormh = calculate_projected_ormh(UV, texture_uv_scale, triplanar_enabled, uv1_power_normal, uv1_triplanar_pos * projected_texture_scale);
				AO = mix(AO, ormh.r, clamp(_blend_ratio, 0.0, 1.0));
				ROUGHNESS = mix(ROUGHNESS, ormh.g, clamp(_blend_ratio, 0.0, 1.0));
				METALLIC = mix(METALLIC, ormh.b, clamp(_blend_ratio, 0.0, 1.0));
				NORMAL_MAP_DEPTH = mix(NORMAL_MAP_DEPTH, ormh.a, clamp(_blend_ratio, 0.0, 1.0));
			}
			
			if (projected_normal_enabled) {

				if ((projected_layer_angle_to_up) < projected_layer_max_angle) {
					
					
					vec4 normal = calculate_projected_normal(UV, projected_texture_scale, triplanar_enabled, uv2_power_normal, uv2_triplanar_pos * projected_texture_scale);
					
					//vec4 projected_normal = triplanar_enabled ?
						//triplanar_texture_rotated(projected_normal_texture, uv1_power_normal, uv1_triplanar_pos * projected_texture_scale, projected_texture_rotation).rgba
						//: texture(projected_normal_texture, UV * texture_uv_scale).rgba;

					NORMAL_MAP = mix(
						NORMAL_MAP,
						normal.rgb * projected_normal_strength,
						clamp(_blend_ratio * projected_normal_blend_amount, 0.0, 1.0)
					);

					NORMAL_MAP_DEPTH = mix(NORMAL_MAP_DEPTH, NORMAL_MAP_DEPTH, clamp(_blend_ratio, 0.0, 1.0));
				}
			}
		}
	}
	
}