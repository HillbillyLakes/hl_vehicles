varying vec2 texture_uv;

group_uniforms primary_albedo;
	uniform bool albedo_enabled = true;
	uniform sampler2D albedo_texture: source_color, filter_linear_mipmap, repeat_enable;
	uniform bool albedo_use_nearest = false;
	uniform sampler2D albedo_texture_nearest: source_color, filter_nearest_mipmap_anisotropic, repeat_enable;
	uniform vec3 albedo_color: source_color = vec3(1.0, 1.0, 1.0);
group_uniforms;