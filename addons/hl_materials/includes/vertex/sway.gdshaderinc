if (horizontal_sway_enabled) {

	float sway_ratio = (COLOR.g * horizontal_sway_amount);

	// Use same noise texture but only use a singular point (position of this node not vertex)
	// to get a value to apply to the entire mesh. We want the whole mesh to sway not separate
	// vertices otherwise it's just leaf noise.
	float _sway_amount = texture(
		wind_noise_texture,
		// Noise scale + time
		(NODE_POSITION_WORLD.xz * sway_scale) + (TIME * 0.025 * horizontal_sway_speed)
	).r;
	
	float sway_x = sway_ratio * _sway_amount * wind_direction.x;
	float sway_z = sway_ratio * _sway_amount * wind_direction.z;

	// Apply sway to horizontal axis
	VERTEX.x += sway_x;
	VERTEX.z += sway_z;


}

if (vertical_sway_enabled) {
	
	float sway_ratio = (COLOR.b * vertical_sway_amount);
	float _sway_amount = texture(
		wind_noise_texture,
		// Noise scale + time
		(NODE_POSITION_WORLD.xz * sway_scale) + (TIME * 0.025 * vertical_sway_speed)
	).r;
	float sway_y = sway_ratio * _sway_amount;
	VERTEX.y += (sway_y);
}