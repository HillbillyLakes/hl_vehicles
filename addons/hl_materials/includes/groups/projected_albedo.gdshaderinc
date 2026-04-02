group_uniforms projected_texture;
	uniform bool projected_texture_enabled = false;
	uniform float projected_texture_scale: hint_range(0.0, 100.0) = 1.0;
	uniform float projected_texture_rotation: hint_range(0.0, 360.0, 0.001) = 0.0;
	uniform float projected_texture_distance: hint_range(0.0, 1000.0, 0.001) = 50.0;
	uniform bool projected_use_nearest = false;
group_uniforms;

group_uniforms projected_albedo;
	uniform bool projected_albedo_enabled = true;
	varying float projected_layer_angle_to_up;
	varying vec2 projected_layer_uv;
	varying vec3 projected_layer_normal;
	uniform float projected_layer_max_angle: hint_range(0.01, 360.0) = 5.0;


	uniform sampler2D projected_albedo_texture: source_color, filter_linear_mipmap, repeat_enable;
	uniform sampler2D projected_albedo_texture_nearest: source_color, filter_nearest_mipmap_anisotropic, repeat_enable;
	
	uniform vec3 projected_albedo_color: source_color = vec3(1.0, 1.0, 1.0);

group_uniforms;