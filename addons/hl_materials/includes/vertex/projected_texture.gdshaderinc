if (projected_texture_enabled) {
	vec3 my_normal = normalize((PROJECTION_MATRIX * vec4(NORMAL, 0.0)).xyz);
	projected_layer_angle_to_up = acos(dot(my_normal, vec3(0.0, -1.0, 0.0))) * 180.0 / PI;
	projected_layer_uv = UV * projected_texture_scale;
	projected_layer_normal = NORMAL;
}