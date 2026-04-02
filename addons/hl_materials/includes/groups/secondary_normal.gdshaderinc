group_uniforms secondary_normal;
	uniform bool secondary_normal_enabled = false;
	uniform sampler2D secondary_normal_texture: source_color, filter_linear_mipmap, repeat_enable;
	uniform float secondary_normal_strength: hint_range(-10.0, 10.0, 0.001) = 1.0;
	uniform float secondary_normal_blend_amount: hint_range(0.0, 1.0, 0.001) = 0.75;
	uniform float secondary_normal_add_amount: hint_range(0.0, 5.0, 0.001) = 0.0;
	uniform sampler2D secondary_normal_texture_nearest: source_color, filter_nearest_mipmap_anisotropic, repeat_enable;
group_uniforms;

#include "res://addons/hl_materials/includes/triplanar_utils.gdshaderinc"

vec4 calculate_secondary_normal(vec2 uv, float uv_scale, bool is_triplanar, vec3 tri_uv_power, vec3 tri_uv_position) {

	if (secondary_use_nearest) {
		vec4 norm_read = is_triplanar ?
			triplanar_texture_nearest(secondary_normal_texture_nearest, tri_uv_power, tri_uv_position * uv_scale).rgba
			: texture(secondary_normal_texture_nearest, uv * uv_scale).rgba;

		vec4 norm = vec4(1.0, 1.0, 1.0, 1.0);
		norm.r = secondary_normal_enabled ? (norm_read.r) : (0.0);
		norm.g = secondary_normal_enabled ? (norm_read.g) : (0.0);
		norm.b = secondary_normal_enabled ? (norm_read.b) : (0.0);

		return norm;
	} else {
		vec4 norm_read = is_triplanar ?
			triplanar_texture(secondary_normal_texture, tri_uv_power, tri_uv_position * uv_scale).rgba
			: texture(secondary_normal_texture, uv * uv_scale).rgba;

		vec4 norm = vec4(1.0, 1.0, 1.0, 1.0);
		norm.r = secondary_normal_enabled ? (norm_read.r) : (0.0);
		norm.g = secondary_normal_enabled ? (norm_read.g) : (0.0);
		norm.b = secondary_normal_enabled ? (norm_read.b) : (0.0);

		return norm;
	}
}
