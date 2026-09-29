package graphics


import gl "vendor:OpenGL"
import strings "core:strings"
import "core:fmt"
import de "../debugger"
import d "../definition"
@private
materials : map[d.MaterialId]^Material
@private
next_material_index : d.MaterialId = 0

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
    ^[3]f32
}
uniform :: proc(value: Uniform_Value) -> Uniform{
    return Uniform{
        location=-999999999,
        value=value
    }
}


load_material :: proc(material: ^Material) -> d.MaterialId{
    materials[next_material_index] = material
    if next_material_index not_in render_object_hierarchy[material.shader]{
        shader_map := render_object_hierarchy[material.shader]
        shader_map[next_material_index] = {}
        render_object_hierarchy[material.shader] = shader_map      
    }
    defer next_material_index+=1
    return next_material_index
}

unload_material :: proc(mat : d.MaterialId){
    material := materials[mat]
    delete_map(material.uniforms)
    free(material)
    delete_key(&materials, mat)
}

unload_all_materials :: proc(){
    for material in materials{
        unload_material(material)
    }
}

@private
bind_material_uniforms :: proc(shader : u32, material : ^Material){
    de.prof_frame_part()
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
            case ^[3]f32:
                fmt.println(v, " : ", v.x, " : ", v.y, " : ", v.z)
                name := strings.clone_to_cstring(key)
                defer delete_cstring(name)
                if uniform.location == -999999999{
                    material.uniforms[key] = {gl.GetUniformLocation(shader,name), v}
                }
                gl.Uniform3f(material.uniforms[key].location, v.x, v.y, v.z)
        }
    }
}

