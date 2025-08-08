shader_type canvas_item;

uniform vec4 glow_color : source_color;
uniform float glow_power = 0.2;
uniform float alpha_threshold = 0.1; // Adjust this value

void fragment() {
    vec4 pixel_color = texture(TEXTURE, UV);

    if (pixel_color.a > alpha_threshold) { // Check for non-transparent pixels
        vec4 glow = glow_color * glow_power;
        // You can adjust how the glow color blends with the original pixel color
        // For example, an additive blend:
        COLOR = pixel_color + glow;
    } else {
        COLOR = pixel_color; // Render transparent pixels as usual
    }
}