group_uniforms secondary_texture;
	uniform bool secondary_texture_enabled = false;
	uniform bool secondary_texture_triplanar = false;
	uniform float secondary_texture_scale: hint_range(0.0, 1000.0, 0.001) = 5.0;
	uniform float secondary_texture_rotation: hint_range(0.0, 360.0, 0.001) = 0.0;
	uniform vec3 secondary_texture_offset = vec3(0.0, 0.0, 0.0);
	uniform float secondary_texture_distance: hint_range(0.0, 1000.0, 0.001) = 50.0;
	uniform bool secondary_use_nearest = false;
group_uniforms;

group_uniforms secondary_albedo;
	uniform bool secondary_albedo_enabled = false;
	uniform sampler2D secondary_albedo_texture: source_color, filter_linear_mipmap, repeat_enable;
	uniform float secondary_albedo_strength: hint_range(0.0, 1.0, 0.001) = 1.0;
	uniform vec3 secondary_albedo_color: source_color = vec3(1.0, 1.0, 1.0);
	uniform sampler2D secondary_albedo_texture_nearest: source_color, filter_nearest_mipmap_anisotropic, repeat_enable;
group_uniforms;