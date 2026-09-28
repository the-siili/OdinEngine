package graphics

import gl "vendor:OpenGL"
import    "core:fmt"
import    "core:os"
import    "base:runtime"
import d "../definition"
import "core:strings"
@private
shaders : map[d.ShaderId]u32
@private
next_shader_index : d.ShaderId = 0

load_shader ::proc(shader_str:string) -> d.ShaderId{
    program_ok      : bool
    shader      : u32

    divided_shaders := strings.split(shader_str, "--")
    defer delete_slice(divided_shaders)
    vertex_str : string = divided_shaders[0]
    fragment_str : string = divided_shaders[1]

    shader, program_ok = gl.load_shaders_source(vertex_str, fragment_str);
    if !program_ok {
        fmt.println("ERROR: Failed to load and compile shaders."); os.exit(1)
    }

    shaders[next_shader_index] = shader
    defer next_shader_index += 1
    return next_shader_index
}

unload_shader ::proc(shader_id:d.ShaderId){
    shader := shaders[shader_id]
    gl.DeleteProgram(shader)
    delete_key(&shaders, shader_id)
}