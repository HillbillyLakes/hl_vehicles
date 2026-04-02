group_uniforms wind;
	// Global shader params for wind. These control wind strength
	// and direction between all things with wind enabled.
	global uniform vec3 wind_direction = vec3(1.0, 0.0, 0.0);
	global uniform float wind_intensity = 1.0;
	global uniform float wind_speed = 1.0;
	
	/**
	 * Applies wind using the vertex paint. The lighter the vertex paint, the more the vertex is affected.
	 */
	uniform bool wind_enabled = false;
	uniform vec3 wind_direction_modifier = vec3(0.0, 0.0, 0.0);
	uniform float wind_amount: hint_range(0.0, 100.0, 0.01) = 1.0;
	uniform float wind_speed_modifer: hint_range(0.0, 5.0, 0.01) = 1.0;
	uniform sampler2D wind_noise_texture;
	uniform float wind_noise_scale: hint_range(0.0, 5.0, 0.01) = 1.0;
group_uniforms;