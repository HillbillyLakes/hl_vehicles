if (wind_enabled) {

	float position_sum = get_position_sum(NODE_POSITION_WORLD);

	vec3 model_front_direction = vec3(1.0, 0.0, 0.0);
	vec3 model_side_direction = vec3(0.0, 0.0, 1.0);

	float dot_product = dot(model_front_direction, wind_direction + wind_direction_modifier);
	float side_dot = dot(model_side_direction, wind_direction + wind_direction_modifier);
	float strength = abs(dot_product);
	
	float push_strength = clamp(strength, 0.05, 1.0);
	float noise_strength = clamp(strength, 0.5, 1.0);

	float scroll_direction = -1.0 * sign(side_dot);
	float scroll_speed = (wind_speed * wind_speed_modifer);

	float wind_uv_scale = 0.1;
	float wind_object_offset = position_sum * 0.5;

	// VERTEX is world coords 
	vec2 wind_uv = vec2(
		(VERTEX.z) * wind_uv_scale 
				+ TIME * scroll_speed * scroll_direction + wind_object_offset,
		(VERTEX.y)
	);

	float wind_noise = texture(wind_noise_texture, wind_uv).r * wind_noise_scale;

	// Unpack wind 0,1 to -1,1
	wind_noise = 2.0 * wind_noise - 1.0;

	// May not need push strength unless it's an attached piece of cloth to a frame.
	VERTEX += wind_direction * 0.05 
			* (wind_intensity * wind_amount)
			* push_strength * COLOR.r;

	VERTEX.x += wind_noise * 0.5
			* (wind_intensity * wind_amount)
			* noise_strength * COLOR.r;
}