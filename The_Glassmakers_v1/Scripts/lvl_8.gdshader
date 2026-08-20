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
    float white_mask = smoothstep(0.75, 0.90, g_src);

    // Neutral curve
    float g = g_src;

    // color palette
	vec3 shadow = vec3(0.22, 0.13, 0.08);
	vec3 tint   = vec3(0.78, 0.56, 0.30);
	vec3 light  = vec3(0.92, 0.84, 0.68);


    vec3 col;

    if (g < 0.30) {
        col = mix(shadow, tint, g / 0.30);
    } else {
        col = mix(tint, light, (g - 0.30) / 0.70);
    }

    // Preserve original whites
    col = mix(col, tex.rgb, white_mask);

    COLOR = vec4(col, tex.a);
}