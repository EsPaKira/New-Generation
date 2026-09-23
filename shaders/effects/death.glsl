vec4 effect() {
    vec4 color = texture(u_screen, v_uv);

    float shake = sin(u_timer * 35.0) * 0.003 + sin(u_timer * 73.0) * 0.002;

    vec2 uv = v_uv;
    uv.x += shake;
    uv.y += sin(u_timer * 51.0) * 0.002;

    color = texture(u_screen, uv);

    float mid = (color.r + color.g + color.b) * 0.333;

    mid *= 0.65;

    color.r = mid * 1.15;
    color.g = mid * 0.15;
    color.b = mid * 0.15;

    return color;
}