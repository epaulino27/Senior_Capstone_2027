shader_type canvas_item;


void fragment() {
    vec4 tex = texture(TEXTURE, UV);
	float g = pow(tex.r, 0.8);
	vec3 tint = vec3(0.75, 0.60, 1.00); // lavender/periwinkle 
	vec3 shadow = vec3(0.10, 0.08, 0.20);
	vec3 col = mix(shadow, tint, g); 
	COLOR = vec4(col, tex.a);
}