group_uniforms sway;
	uniform bool horizontal_sway_enabled = false;
	uniform float horizontal_sway_amount: hint_range(0.0, 250.0, 0.01) = 1.0;
	uniform float horizontal_sway_speed: hint_range(0.0, 5.0, 0.01) = 1.0;
	uniform bool vertical_sway_enabled = false;
	uniform float vertical_sway_amount: hint_range(0.0, 250.0, 0.01) = 1.0;
	uniform float vertical_sway_speed: hint_range(0.0, 5.0, 0.01) = 1.0;
	uniform float sway_scale: hint_range(0.0, 0.1, 0.001) = 0.01;
group_uniforms;