group_uniforms alpha;
	uniform bool alpha_enabled = false;
	uniform float alpha_threshold: hint_range(0.0, 1.0, 0.001) = 0.15;
group_uniforms;