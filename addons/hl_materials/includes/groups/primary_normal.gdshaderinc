group_uniforms primary_normal;
	uniform bool normal_enabled = false;
	uniform bool force_front_normals = false;
	uniform bool use_spherical_normals = false;
	uniform sampler2D normal_texture: source_color, filter_linear_mipmap, repeat_enable;
	uniform bool normal_use_nearest = false;
	uniform sampler2D normal_texture_nearest: source_color, filter_nearest_mipmap_anisotropic, repeat_enable;
	uniform float normal_strength: hint_range(-10.0, 10.0, 0.001) = 1.0;
group_uniforms;

#include "res://addons/hl_materials/includes/triplanar_utils.gdshaderinc"

vec4 calculate_normal(vec2 uv, float uv_scale, bool is_triplanar, vec3 tri_uv_power, vec3 tri_uv_position) {

	if (normal_use_nearest) {
		vec4 norm_read = is_triplanar ?
			triplanar_texture_nearest(normal_texture_nearest, tri_uv_power, tri_uv_position).rgba
			: texture(normal_texture_nearest, uv * uv_scale).rgba;

		vec4 norm = vec4(1.0, 1.0, 1.0, 1.0);
		norm.r = normal_enabled ? (norm_read.r) : (0.0);
		norm.g = normal_enabled ? (norm_read.g) : (0.0);
		norm.b = normal_enabled ? (norm_read.b) : (0.0);

		return norm * normal_strength;
	} else {
		vec4 norm_read = is_triplanar ?
			triplanar_texture(normal_texture, tri_uv_power, tri_uv_position).rgba
			: texture(normal_texture, uv * uv_scale).rgba;

		vec4 norm = vec4(1.0, 1.0, 1.0, 1.0);
		norm.r = normal_enabled ? (norm_read.r) : (0.0);
		norm.g = normal_enabled ? (norm_read.g) : (0.0);
		norm.b = normal_enabled ? (norm_read.b) : (0.0);

		return norm * normal_strength;
	}
}
