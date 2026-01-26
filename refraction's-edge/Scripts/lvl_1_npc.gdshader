shader_type canvas_item;


void fragment() {
	//for every pixel
	vec4 tex = texture(TEXTURE, UV);
	//get origional color
	float g = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	//set highlights/shadows used to edit pixels
	vec3 shadow = vec3(0.35, 0.40, 0.55); 
	vec3 tint = vec3(1.4, 1.55, 2.8);
	//alter pixels with tint/shadow and set new color
	vec3 col = mix(shadow, tint, g); 
	COLOR = vec4(col, tex.a);
}