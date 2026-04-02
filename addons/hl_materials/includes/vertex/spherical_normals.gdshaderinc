if (use_spherical_normals) {
	// As suggested by Tokisan Games.
	NORMAL = normalize(VERTEX); // Recalculate vertex normals from model origin
	TANGENT = normalize(cross(NORMAL, vec3(0., 0., 1.)));
	BINORMAL = normalize(cross(NORMAL, TANGENT));
}