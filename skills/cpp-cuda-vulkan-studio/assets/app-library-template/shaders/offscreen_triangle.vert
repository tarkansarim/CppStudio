#version 450

layout(location = 0) out vec3 triangle_color;

vec2 fullscreen_positions[3] = vec2[](
    vec2(-1.0, -1.0),
    vec2(3.0, -1.0),
    vec2(-1.0, 3.0)
);

void main() {
    gl_Position = vec4(fullscreen_positions[gl_VertexIndex], 0.0, 1.0);
    triangle_color = vec3(0.0, 1.0, 0.0);
}
