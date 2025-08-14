shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque, blend_add;

uniform float time_scale : hint_range(0.0, 4.0) = 1.6;
uniform float jaggedness : hint_range(0.0, 20.0) = 8.0;
uniform float core_width : hint_range(0.0, 1.0) = 0.12;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(41.0, 289.0))) * 43758.5453);
}

float noise(vec2 p){
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(a,b,u.x), mix(c,d,u.x), u.y);
}

void fragment(){
    // UV.y runs along the bolt (0 bottom → 1 top)
    // UV.x is across the bolt’s width
    float t = TIME * time_scale;
    vec2 p = UV;
    // Horizontal displacement that changes with y and time
    float jag = (noise(vec2(p.y * jaggedness, t)) - 0.5) * 0.6;
    float x = abs(p.x - 0.5 + jag);         // distance from lightning “spine”
    // Thickness tapers toward ends:
    float width = core_width * (0.4 + 0.6 * (1.0 - abs(p.y - 0.5) * 2.0));
    float core = smoothstep(width, 0.0, x);

    // Soft halo
    float halo = smoothstep(0.5, 0.0, x);
    float a = clamp(core + 0.35 * halo, 0.0, 1.0);

    ALBEDO = vec3(1.0);
    EMISSION = vec3(6.0) * a;
    ALPHA = a;
}
