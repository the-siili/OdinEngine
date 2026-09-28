package graphics


import gl "vendor:OpenGL"
import strings "core:strings"
import de "../debugger"

Material :: struct{
    shader: i32,
    uniforms:map[string]Uniform
}
Uniform :: struct {
    location: i32,
    value:Uniform_Value
}

Uniform_Value :: union {
    i32,
    f32,
    [2]f32,
    [3]f32
}
uniform :: proc(value: Uniform_Value) -> Uniform{
    return Uniform{
        location=-999999999,
        value=value
    }
}

@private
bind_material_uniforms :: proc(shader : u32, material : ^Material){
    tex_count :u32= 0
    for key, uniform in material.uniforms{
        switch v in uniform.value {
            case i32:
                name := strings.clone_to_cstring(key)
                defer delete_cstring(name)
                if uniform.location == -999999999{
                    material.uniforms[key] = {gl.GetUniformLocation(shader,name), v}
                }
                gl.Uniform1i(material.uniforms[key].location, i32(tex_count))
                gl.ActiveTexture(gl.TEXTURE0 + tex_count); 
                gl.BindTexture(gl.TEXTURE_2D, textures[v]);
                tex_count += 1
            case f32:
                name := strings.clone_to_cstring(key)
                defer delete_cstring(name)
                if uniform.location == -999999999{
                    material.uniforms[key] = {gl.GetUniformLocation(shader,name), v}
                }
                gl.Uniform1f(material.uniforms[key].location, v)
            case [2]f32:
                name := strings.clone_to_cstring(key)
                defer delete_cstring(name)
                if uniform.location == -999999999{
                    material.uniforms[key] = {gl.GetUniformLocation(shader,name), v}
                }
                gl.Uniform2f(material.uniforms[key].location, v.x, v.y)
            case [3]f32:
                name := strings.clone_to_cstring(key)
                defer delete_cstring(name)
                if uniform.location == -999999999{
                    material.uniforms[key] = {gl.GetUniformLocation(shader,name), v}
                }
                gl.Uniform3f(material.uniforms[key].location, v.x, v.y, v.z)

        }
    }
}
