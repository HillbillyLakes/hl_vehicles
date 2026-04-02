
group_uniforms secondary_o_r_m_h;
	uniform sampler2D secondary_ormh_texture: source_color, filter_linear_mipmap, repeat_enable;
	uniform sampler2D secondary_ormh_texture_nearest: source_color, filter_nearest_mipmap_anisotropic, repeat_enable;

	uniform bool secondary_ao_enabled = false;
	uniform float secondary_ao_strength: hint_range(0.0, 1.0, 0.001) = 1.0;

	uniform bool secondary_roughness_enabled = false;
	uniform float secondary_roughness_strength: hint_range(0.0, 1.0, 0.001) = 1.0;

	uniform bool secondary_metallic_enabled = false;
	uniform float secondary_metallic_strength: hint_range(0.0, 1.0, 0.001) = 1.0;

	uniform bool secondary_height_enabled = false;
	uniform float secondary_height_strength: hint_range(-5.0, 5.0, 0.001) = 2.5;

group_uniforms;

#include "res://addons/hl_materials/includes/triplanar_utils.gdshaderinc"

vec4 calculate_secondary_ormh(vec2 uv, float uv_scale, bool is_triplanar, vec3 tri_uv_power, vec3 tri_uv_position) {

	if (secondary_use_nearest) {
		vec4 orm_read = is_triplanar ?
			triplanar_texture_nearest(secondary_ormh_texture_nearest, tri_uv_power, tri_uv_position).rgba
			: texture(secondary_ormh_texture_nearest, uv * uv_scale).rgba;

		vec4 orm = vec4(1.0, 1.0, 1.0, 1.0);
		orm.r = secondary_ao_enabled ? (orm_read.r * secondary_ao_strength) : (0.0);
		orm.g = secondary_roughness_enabled ? (orm_read.g * secondary_roughness_strength) : (1.0);
		orm.b = secondary_metallic_enabled ? (orm_read.b * secondary_metallic_strength) : (0.0);
		orm.a = secondary_height_enabled ? (orm_read.a * secondary_height_strength) : (1.0);

		return orm;
	} else {
		vec4 orm_read = is_triplanar ?
			triplanar_texture(secondary_ormh_texture, tri_uv_power, tri_uv_position).rgba
			: texture(secondary_ormh_texture, uv * uv_scale).rgba;

		vec4 orm = vec4(1.0, 1.0, 1.0, 1.0);
		orm.r = secondary_ao_enabled ? (orm_read.r * secondary_ao_strength) : (0.0);
		orm.g = secondary_roughness_enabled ? (orm_read.g * secondary_roughness_strength) : (1.0);
		orm.b = secondary_metallic_enabled ? (orm_read.b * secondary_metallic_strength) : (0.0);
		orm.a = secondary_height_enabled ? (orm_read.a * secondary_height_strength) : (1.0);

		return orm;
	}
}