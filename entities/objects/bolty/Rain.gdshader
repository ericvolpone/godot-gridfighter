shader_type spatial;
// Billboard makes each quad face the camera.
// Additive + transparent so small streaks glow and don't write depth.
render_mode unshaded, cull_disabled, blend_add, depth_draw_never, billboard;

uniform vec3 drop_color : source_color = vec3(0.6, 0.8, 1.0);
uniform float glow_strength : hint_range(0.0, 10.0) = 2.0;
uniform float width : hint_range(0.0, 1.0) = 0.12;
uniform float taper : hint_range(0.0, 1.0) = 0.15;

void fragment() {
    // Vertical streak centered in X, tapered at ends
    float x = abs(UV.x - 0.5);
    float core = smoothstep(width, 0.0, x); // thin center column
    float ends = smoothstep(0.0, taper, UV.y) * smoothstep(1.0, 1.0 - taper, UV.y);
    float a = core * ends;

    ALBEDO = vec3(0.0);                // emission-only
    EMISSION = drop_color * glow_strength * a;
    ALPHA = a;                          // make sure this isn’t 0!
}
