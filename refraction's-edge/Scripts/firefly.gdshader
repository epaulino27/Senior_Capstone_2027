shader_type canvas_item;

//able to use on sprites, ui elements, etc.
 void fragment() {
	//do this for each pixel
	vec4 tex = texture(TEXTURE, UV); 
	//get starting color values
	float g = tex.r; // grayscale
	//set tint
	vec3 tint = vec3(1.45, 1.30, 0.75); 
	//reassign color after its been tinted
	COLOR = vec4(g * tint, tex.a); }