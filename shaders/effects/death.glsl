vec4 effect() {
    vec4 color = texture(u_screen, v_uv);
    color = texture(u_screen, v_uv + color.rg * (0.1 + sin(u_timer * 1211.5) * 0.02));
    float mid = (color.r + color.g + color.b) * 0.1 * 3;
    return vec4(color.r, mid, mid, 0.7);
}
