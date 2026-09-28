package resource

import ge "../graphics"
import "core:strings"
import os "core:os"
import d "../definition"
import "core:fmt"

loaded_shaders :map[string]i32={}

load_shaders :: proc(paths : []string){
    new_shaders: map[string]struct{} = {}
    for path in paths{
        parts := strings.split(path, "/")
        defer delete_slice(parts)
        name := parts[len(parts)-1]
        if name in loaded_shaders{
            new_shaders[name] = {}
            continue
        }
        file_data, err := os.read_entire_file(path, context.allocator)
        defer delete_slice(file_data)
        if err != nil{
            fmt.println(err)
        }
        v, i := ge.load_obj(string(file_data))
        loaded_shaders[name] = ge.load_shader(string(file_data))
        new_shaders[name] = {}
    }
    for name in loaded_shaders{
        if name not_in new_shaders{
            ge.unload_shader(loaded_shaders[name])
            delete_key(&loaded_shaders, name)
        }
    }
    delete_map(new_shaders)
}
unload_shaders :: proc(){
    for name in loaded_shaders{
        ge.unload_shader(loaded_shaders[name])
        delete_key(&loaded_shaders, name)
    }
}
get_shader_id ::proc(name:string) -> d.ShaderId{
    return loaded_shaders[name]
}