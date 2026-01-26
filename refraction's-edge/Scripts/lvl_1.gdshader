shader_type canvas_item;


void fragment() {
	//for each pixel
    vec4 tex = texture(TEXTURE, UV);
	//get the starting color value
	float g = pow(tex.r, 0.8);
	//set tint and shadow your going to change pixels with
	vec3 tint = vec3(0.30, 0.40, 0.70);
	vec3 shadow = vec3(0.082, 0.133, 0.219);
	//blend tint and shadow to get midtones as well
	//note made like this to try and encourage contrast between npcs, players, and background
	vec3 col = mix(shadow, tint, g); 
	COLOR = vec4(col, tex.a);
}