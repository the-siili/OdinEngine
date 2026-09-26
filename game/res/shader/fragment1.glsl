#version 330 core

in vec2 uv;
in vec3 pos;
out vec4 FragColor;

uniform sampler2D texture0;
uniform sampler2D texture1;

uniform vec3 loc;
uniform vec3 camera_loc;
void main() {

        float dist = sqrt(pow(abs(pos.x-camera_loc.x), 2) + pow(abs(pos.y-camera_loc.y), 2) + pow(abs(pos.z-camera_loc.z), 2));
        vec4 col = texture(texture0, uv);
        FragColor = vec4(col.xyz, 1.0);

        //FragColor = vec4(0, abs(loc.y)/3.0, 0,  1.0);

}

