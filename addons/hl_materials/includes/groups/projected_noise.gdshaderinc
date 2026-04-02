
group_uniforms projected_thickness;

	uniform bool projected_noise_triplanar = false;
	uniform float projected_thickness: hint_range(0.0, 10.0, 0.001) = 1.0;

	uniform sampler2D projected_noise_texture: source_color, filter_linear_mipmap, repeat_enable;
	uniform sampler3D projected_noise3d_texture: source_color, filter_linear_mipmap, repeat_enable;
	uniform float projected_noise_amount: hint_range(0.0, 10.0, 0.001) = 1.0;

group_uniforms;