
group_uniforms primary_o_r_m_h;

	uniform sampler2D ormh_texture: source_color, filter_linear_mipmap, repeat_enable;
	uniform bool ormh_use_nearest = false;
	uniform sampler2D ormh_texture_nearest: source_color, filter_nearest_mipmap_anisotropic, repeat_enable;

	uniform bool ao_enabled = false;
	uniform float ao_strength: hint_range(0.0, 1.0, 0.001) = 1.0;

	uniform bool roughness_enabled = false;
	uniform float roughness_strength: hint_range(0.0, 5.0, 0.001) = 1.0;

	uniform bool metallic_enabled = false;
	uniform float metallic_strength: hint_range(0.0, 1.0, 0.001) = 1.0;

	uniform bool height_enabled = false;
	uniform float height_strength: hint_range(-2.0, 2.0, 0.001) = 1.0;

group_uniforms;

#include "res://addons/hl_materials/includes/triplanar_utils.gdshaderinc"

vec4 calculate_ormh(vec2 uv, float uv_scale, bool is_triplanar, vec3 tri_uv_power, vec3 tri_uv_position) {

	if (ormh_use_nearest) {
		vec4 orm_read = is_triplanar ?
			triplanar_texture_nearest(ormh_texture_nearest, tri_uv_power, tri_uv_position).rgba
			: texture(ormh_texture_nearest, uv * uv_scale).rgba;

		vec4 orm = vec4(1.0, 1.0, 1.0, 1.0);
		orm.r = ao_enabled ? (orm_read.r * ao_strength) : (0.0);
		orm.g = roughness_enabled ? (orm_read.g * roughness_strength) : (1.0);
		orm.b = metallic_enabled ? (orm_read.b * metallic_strength) : (0.0);
		orm.a = height_enabled ? (orm_read.a * height_strength) : (1.0);

		return orm;
	}
	 else {
		vec4 orm_read = is_triplanar ?
			triplanar_texture(ormh_texture, tri_uv_power, tri_uv_position).rgba
			: texture(ormh_texture, uv * uv_scale).rgba;

		vec4 orm = vec4(1.0, 1.0, 1.0, 1.0);
		orm.r = ao_enabled ? (orm_read.r * ao_strength) : (0.0);
		orm.g = roughness_enabled ? clamp((orm_read.g * roughness_strength), 0.0, 1.0) : (1.0);
		//orm.g = roughness_enabled ? (orm_read.g * roughness_strength) : (1.0);
		orm.b = metallic_enabled ? (orm_read.b * metallic_strength) : (0.0);
		orm.a = height_enabled ? (orm_read.a * height_strength) : (1.0);

		return orm;
	}
}