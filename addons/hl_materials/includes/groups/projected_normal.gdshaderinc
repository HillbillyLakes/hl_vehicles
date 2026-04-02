group_uniforms projected_normal;
	uniform bool projected_normal_enabled = false;
	uniform sampler2D projected_normal_texture: source_color, filter_linear_mipmap, repeat_enable;
	uniform sampler2D projected_normal_texture_nearest: source_color, filter_nearest_mipmap_anisotropic, repeat_enable;
	uniform float projected_normal_strength: hint_range(-2.0, 2.0, 0.001) = 1.0;
	uniform float projected_normal_blend_amount: hint_range(0.0, 1.0, 0.001) = 0.75;
group_uniforms;

#include "res://addons/hl_materials/includes/triplanar_utils.gdshaderinc"

vec4 calculate_projected_normal(vec2 uv, float uv_scale, bool is_triplanar, vec3 tri_uv_power, vec3 tri_uv_position) {

	if (projected_use_nearest) {
		vec4 norm_read = is_triplanar ?
			triplanar_texture_nearest(projected_normal_texture_nearest, tri_uv_power, tri_uv_position).rgba
			: texture(projected_normal_texture_nearest, uv * uv_scale).rgba;

		vec4 norm = vec4(1.0, 1.0, 1.0, 1.0);
		norm.r = projected_normal_enabled ? (norm_read.r) : (0.0);
		norm.g = projected_normal_enabled ? (norm_read.g) : (0.0);
		norm.b = projected_normal_enabled ? (norm_read.b) : (0.0);

		return norm;
	} else {
		//vec4 norm_read = is_triplanar ?
			//triplanar_texture(projected_normal_texture, tri_uv_power, tri_uv_position).rgba
			//: texture(projected_normal_texture, uv * uv_scale).rgba;
		vec4 norm_read = is_triplanar ?
			triplanar_texture(projected_normal_texture, tri_uv_power, tri_uv_position).rgba
			: texture(projected_normal_texture, uv * uv_scale).rgba;

		//vec4 norm_read = calculate_normal(uv, uv_scale, is_triplanar, tri_uv_power, tri_uv_position);

		vec4 norm = vec4(1.0, 1.0, 1.0, 1.0);
		norm.r = projected_normal_enabled ? (norm_read.r) : (0.0);
		norm.g = projected_normal_enabled ? (norm_read.g) : (0.0);
		norm.b = projected_normal_enabled ? (norm_read.b) : (0.0);

		return norm;
	}
}
