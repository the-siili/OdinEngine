#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aUv;

uniform mat4 view_mat;
uniform mat4 perspective_mat;

out vec2 uv;
void main() {

    mat4 view_rot = view_mat;
    view_rot[3][0] = 0;
    view_rot[3][1] = 0;
    view_rot[3][2] = 0;
    gl_Position =
        perspective_mat *
        view_rot *
        vec4(aPos, 1.0);
    uv = aUv.xy;
}

--
#version 330 core

in vec2 uv;
out vec4 FragColor;

uniform sampler2D texture0;

void main() {
        vec4 col = texture(texture0, uv);
        FragColor = vec4(col.xyz, 1.0);
        //FragColor = vec4(uv.x, uv.y, 0.0, 1.0);
        //FragColor = vec4(0, sin(uv.x), 0,  1.0);

}


