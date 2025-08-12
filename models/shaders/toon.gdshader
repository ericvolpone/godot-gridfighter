shader_type spatial;
render_mode cull_front, depth_draw_never; // ← important

uniform vec4  albedo_color : source_color = vec4(1, 1, 1, 1.0);
uniform float light_steps  = 3.0;   // band count
uniform float rim_intensity = 0.4;  // 0 disables rim
uniform float rim_power     = 2.0;
uniform float spec_intensity = 0.25;
uniform float spec_shininess = 64.0;

void fragment() {
    ALBEDO = albedo_color.rgb;
    ALPHA  = albedo_color.a;
}

void light() {
    // Diffuse, banded
    float ndotl   = max(dot(NORMAL, normalize(LIGHT)), 0.0);
    float bands   = max(light_steps, 1.0);
    float stepped = floor(ndotl * bands) / bands;

    // Rim
    float vdotn = max(dot(NORMAL, VIEW), 0.0);
    float rim   = pow(1.0 - vdotn, rim_power) * rim_intensity;

    // Specular (Blinn-Phong)
    vec3  H    = normalize(normalize(LIGHT) + VIEW);
    float spec = pow(max(dot(NORMAL, H), 0.0), spec_shininess) * spec_intensity;

    // ATTENUATION already includes shadow + distance
    vec3 lit = LIGHT_COLOR * ATTENUATION;

    DIFFUSE_LIGHT  += ALBEDO * (stepped + rim) * lit;
    SPECULAR_LIGHT += spec * lit;
}