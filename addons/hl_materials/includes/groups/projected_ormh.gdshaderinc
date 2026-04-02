
group_uniforms projected_o_r_m_h;
	uniform sampler2D projected_ormh_texture: source_color, filter_linear_mipmap, repeat_enable;
	uniform sampler2D projected_ormh_texture_nearest: source_color, filter_nearest_mipmap_anisotropic, repeat_enable;

	uniform bool projected_ao_enabled = false;
	uniform float projected_ao_strength: hint_range(0.0, 1.0, 0.001) = 1.0;

	uniform bool projected_roughness_enabled = false;
	uniform float projected_roughness_strength: hint_range(0.0, 1.0, 0.001) = 1.0;

	uniform bool projected_metallic_enabled = false;
	uniform float projected_metallic_strength: hint_range(0.0, 1.0, 0.001) = 1.0;
	
	uniform bool projected_height_enabled = false;
	uniform float projected_height_strength: hint_range(0.0, 2.0, 0.001) = 1.0;

group_uniforms;

#include "res://addons/hl_materials/includes/triplanar_utils.gdshaderinc"

vec4 calculate_projected_ormh(vec2 uv, float uv_scale, bool is_triplanar, vec3 tri_uv_power, vec3 tri_uv_position) {

	if (projected_use_nearest) {
		vec4 orm_read = is_triplanar ?
			triplanar_texture_nearest(projected_ormh_texture_nearest, tri_uv_power, tri_uv_position).rgba
			: texture(projected_ormh_texture_nearest, uv * uv_scale).rgba;

		vec4 orm = vec4(1.0, 1.0, 1.0, 1.0);
		orm.r = projected_ao_enabled ? (orm_read.r * projected_ao_strength) : (0.0);
		orm.g = projected_roughness_enabled ? (orm_read.g * projected_roughness_strength) : (1.0);
		orm.b = projected_metallic_enabled ? (orm_read.b * projected_metallic_strength) : (0.0);
		orm.a = projected_height_enabled ? (orm_read.a * projected_height_strength) : (1.0);

		return orm;
	} else {
		vec4 orm_read = is_triplanar ?
			triplanar_texture(projected_ormh_texture, tri_uv_power, tri_uv_position).rgba
			: texture(projected_ormh_texture, uv * uv_scale).rgba;

		vec4 orm = vec4(1.0, 1.0, 1.0, 1.0);
		orm.r = projected_ao_enabled ? (orm_read.r * projected_ao_strength) : (0.0);
		orm.g = projected_roughness_enabled ? (orm_read.g * projected_roughness_strength) : (1.0);
		orm.b = projected_metallic_enabled ? (orm_read.b * projected_metallic_strength) : (0.0);
		orm.a = projected_height_enabled ? (orm_read.a * projected_height_strength) : (1.0);

		return orm;
	}
}