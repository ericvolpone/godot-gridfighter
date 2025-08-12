shader_type spatial;
render_mode cull_back, world_vertex_coords; // <- key flag

uniform vec4 grass_light : source_color = vec4(0.80, 0.95, 0.65, 1.0);
uniform vec4 grass_dark  : source_color = vec4(0.50, 0.80, 0.45, 1.0);
uniform vec4 dirt_color  : source_color = vec4(0.35, 0.25, 0.18, 1.0);

uniform sampler2D noise_tex;        // tiling noise (Perlin/FBM). Set Repeat=On
uniform float noise_scale = 0.35;   // patch size
uniform float patch_contrast = 1.2; // >1 = stronger patches

uniform float slope_start = 0.55;   // start blending to dirt when N.y < this
uniform float slope_end   = 0.35;   // fully dirt by here

uniform float band_steps  = 3.0;    // toon band count
uniform float roughness   = 0.7;
uniform float specular    = 0.05;

// we'll pass world-space data through varyings
varying vec3 v_world_pos;
varying vec3 v_world_norm;

void vertex() {
    // with world_vertex_coords, VERTEX/NORMAL are already world-space
    v_world_pos  = VERTEX;
    v_world_norm = normalize(NORMAL);
}

vec3 triplanar_sample_rgb(sampler2D tex, vec3 wp, vec3 n, float scale){
    vec3 an = abs(n) + 1e-5;
    an /= (an.x + an.y + an.z);

    vec2 uvx = wp.zy * scale; // project on X
    vec2 uvy = wp.xz * scale; // project on Y (top)
    vec2 uvz = wp.xy * scale; // project on Z

    vec3 cx = texture(tex, uvx).rgb;
    vec3 cy = texture(tex, uvy).rgb;
    vec3 cz = texture(tex, uvz).rgb;
    return cx * an.x + cy * an.y + cz * an.z;
}

void fragment(){
    ALPHA = 1.0;

    vec3 wp = v_world_pos;
    vec3 wn = normalize(v_world_norm);

    // patchy grass color from noise
    float n = triplanar_sample_rgb(noise_tex, wp, wn, noise_scale).r;
    n = pow(n, patch_contrast);
    vec3 grass = mix(grass_dark.rgb, grass_light.rgb, n);

    // slope-based dirt blend
    float t = clamp((wn.y - slope_end) / max(1e-5, (slope_start - slope_end)), 0.0, 1.0);
    ALBEDO = mix(dirt_color.rgb, grass, t);

    ROUGHNESS = roughness;
    SPECULAR  = specular;
}

void light(){
    // toon bands
    float ndotl = max(dot(NORMAL, LIGHT), 0.0);
    float steps = max(band_steps, 1.0);
    float stepped = floor(ndotl * steps) / steps;

    vec3 lit = LIGHT_COLOR * ATTENUATION; // shadows baked into ATTENUATION
    DIFFUSE_LIGHT += ALBEDO * stepped * lit;
}
