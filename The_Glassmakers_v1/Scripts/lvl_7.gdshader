shader_type canvas_item;
render_mode unshaded;

// Required in Godot 4
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Sample the screen
    vec4 tex = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Original luminance
    float g_src = dot(tex.rgb, vec3(0.299, 0.587, 0.114));

    // Preserve bright whites
	float white_mask = smoothstep(0.85, 0.98, g_src);

    // Neutral curve
    float g = g_src;

    // color palette
	vec3 shadow = vec3(0.20, 0.00, 0.08);
	vec3 tint   = vec3(0.80, 0.68, 0.20);
	vec3 light = vec3(0.95, 0.90, 0.70);

    vec3 col;

	 if (g < 0.45) {
	    col = mix(shadow, tint, g / 0.45);
	} else {
	    col = mix(tint, light, (g - 0.45) / 0.55);
	}

    // Preserve original whites
    col = mix(col, tex.rgb, white_mask);

    COLOR = vec4(col, tex.a);
}