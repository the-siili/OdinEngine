#version 330 core

in vec3 pos_col;

out vec4 FragColor;

void main() {
        FragColor = vec4(pos_col.x, 0.5, 0.5, 1);
}

