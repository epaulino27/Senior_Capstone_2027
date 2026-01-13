shader_type canvas_item;
 void fragment() {
	 vec4 tex = texture(TEXTURE, UV); 
	float g = tex.r; // grayscale
	 vec3 tint = vec3(1.45, 1.30, 0.75); 
	COLOR = vec4(g * tint, tex.a); }