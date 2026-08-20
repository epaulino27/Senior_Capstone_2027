shader_type canvas_item;
render_mode unshaded;

// Required in Godot 4
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Sample the screen
    vec4 tex = texture(SCREEN_TEXTURE, SCREEN_UV);

    // ORIGINAL luminance
    float g_src = dot(tex.rgb, vec3(0.299, 0.587, 0.114));

    // White preservation mask
    float white_mask = smoothstep(0.70, 0.85, g_src);

    // Contrast-adjusted luminance
    float g = pow(g_src, 1.35);

    // Palette
    vec3 shadow = vec3(0.07, 0.09, 0.18);
    vec3 tint   = vec3(0.34, 0.34, 0.68);
    vec3 light  = vec3(0.92, 0.93, 0.95);

    // Palette blend
    vec3 col;
    if (g < 0.45) {
        col = mix(shadow, tint, g / 0.45);
    } else {
        col = mix(tint, light, (g - 0.45) / 0.55);
    }

    // Preserve whites
    col = mix(col, tex.rgb, white_mask);

    COLOR = vec4(col, tex.a);
}
