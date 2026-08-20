shader_type canvas_item;

void fragment() {
	//get current texture color
    vec4 tex = texture(TEXTURE, UV);

	//convert from color to greyscale
	//NOTE: despite the origional pallete being greyscale I use this as a failsafe for consistencies sake
    float g_src = dot(tex.rgb, vec3(0.299, 0.587, 0.114));

	//preserve near-white pixels from being tinted
    float white_mask = smoothstep(0.70, 0.85, g_src);

	//slightly darken midtones for stronger contrast
    float g = pow(g_src, 1.35);

	//color palette
	vec3 shadow = vec3(0.10, 0.14, 0.23);
	vec3 tint = vec3(0.62, 0.76, 0.94);
	vec3 light = vec3(0.98, 0.99, 1.00);

    vec3 col;

	//blend from shadow to tint in darker areas
    if (g < 0.45) {
        col = mix(shadow, tint, g / 0.45);
    }
	//blend from tint to light in brighter areas
    else {
        col = mix(tint, light, (g - 0.45) / 0.55);
    }

	//restore original white pixels from before
    col = mix(col, tex.rgb, white_mask);

	//output final color while preserving transparency
    COLOR = vec4(col, tex.a);
}