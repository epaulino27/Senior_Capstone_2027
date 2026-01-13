shader_type canvas_item;


void fragment() {
    vec4 tex = texture(TEXTURE, UV);
	float g = pow(tex.r, 0.8);
	vec3 tint = vec3(0.30, 0.40, 0.70);
	vec3 shadow = vec3(0.082, 0.133, 0.219);
	vec3 col = mix(shadow, tint, g); 
	COLOR = vec4(col, tex.a);
}