#version 330 core
layout (location = 0) in vec3 aPos;

uniform mat4 model_mat;
uniform mat4 view_mat;
uniform mat4 perspective_mat;

out vec3 pos_col;

void main() {
    gl_Position =
        perspective_mat *
        view_mat *
        model_mat *
        vec4(aPos, 1.0);
    pos_col = gl_Position.xyz;
    
}