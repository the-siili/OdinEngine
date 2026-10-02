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

--
#version 330 core

in vec2 uv;
in vec3 pos;
out vec4 FragColor;

uniform sampler2D texture0;

uniform vec3 loc;
uniform vec3 camera_loc;
uniform float uv_scale;
uniform float time;
float lighting_far = 20.0;
float lighting_close = 1.0;
float light_intensity = 1.0;
vec3 light_color = vec3(1, 1, 1);
void main() {
        vec3 light_source = vec3(0, 0, 10.0);
        float dist = clamp(sqrt(pow(pos.x-light_source.x, 2)+pow(pos.y-light_source.y, 2)+pow(pos.z-light_source.z, 2)), lighting_close, lighting_far);
        dist = 1-(dist - lighting_close) / (lighting_far - lighting_close);
        vec4 col = texture(texture0, uv*uv_scale);
        FragColor = vec4(col.xyz*dist*light_color*light_intensity, 1.0);

        //FragColor = vec4(0, sin(uv.x), 0,  1.0);

}


