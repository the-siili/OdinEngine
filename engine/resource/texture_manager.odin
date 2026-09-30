package resource

import ge "../graphics"
import "core:strings"
import os "core:os"
import d "../definition"
import "core:fmt"

loaded_textures :map[string]i32={}

TextureInfo :: struct{
    path:string,
    wrap_mode : i32,
    filter_mode : i32
}

load_textures :: proc(texture_array: []TextureInfo){
    new_textures: map[string]struct{} = {}
    for texture_info in texture_array{
        path := texture_info.path
        parts := strings.split(path, "/")
        defer delete_slice(parts)
        name := parts[len(parts)-1]
        if name in loaded_textures{
            new_textures[name] = {}
            continue
        }
        file_data, err := os.read_entire_file(path, context.allocator)
        defer delete_slice(file_data)
        if err != nil{
            fmt.println(err)
        }

        loaded_textures[name] = ge.load_texture(file_data, 
                                                texture_info.wrap_mode, texture_info.wrap_mode,
                                            texture_info.filter_mode, texture_info.filter_mode)
        new_textures[name] = {}
    }
    for name in loaded_textures{
        if name not_in new_textures{
            ge.unload_texture(loaded_textures[name])
            delete_key(&loaded_textures, name)
        }
    }
    delete_map(new_textures)
}
unload_textures :: proc(){
    for name in loaded_textures{
        ge.unload_texture(loaded_textures[name])
        delete_key(&loaded_textures, name)
    }
}
get_texture_id ::proc(name:string) -> d.TextureId{
    return loaded_textures[name]
}