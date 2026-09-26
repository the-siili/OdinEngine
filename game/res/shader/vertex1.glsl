#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aUv;

uniform mat4 model_mat;
uniform mat4 view_mat;
uniform mat4 perspective_mat;
uniform vec3 loc;

out vec2 uv;
out vec3 pos;
void main() {
    gl_Position =
        perspective_mat *
        view_mat *
        model_mat *
        vec4(aPos, 1.0);
    uv = aUv.xy;
    pos = vec3(model_mat * vec4(aPos, 1.0));
}