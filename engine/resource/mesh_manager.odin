package resource

import ge "../graphics"
import "core:strings"
import os "core:os"
import d "../definition"
import "core:fmt"
loaded_meshes :map[string]i32={}

load_obj_models :: proc(paths : []string){
    new_meshes: map[string]struct{} = {}
    for path in paths{
        parts := strings.split(path, "/")
        defer delete_slice(parts)
        name := parts[len(parts)-1]
        if name in loaded_meshes{
            new_meshes[name] = {}
            continue
        }

        file_data, err := os.read_entire_file(path, context.allocator)
        defer delete_slice(file_data)
        if err != nil{
            fmt.println(err)
        }
        v, i := ge.load_obj(string(file_data))
        loaded_meshes[name] = ge.load_mesh(v, i)
        
        new_meshes[name] = {}
    }

    for name in loaded_meshes{
        
        if name not_in new_meshes{
            
            ge.unload_mesh(loaded_meshes[name])
            
            delete_key(&loaded_meshes, name)
            
        }
    }
    delete_map(new_meshes)
}

load_azub_models :: proc(paths : []string){
    new_meshes: map[string]struct{} = {}
    for path in paths{
        parts := strings.split(path, "/")
        defer delete_slice(parts)
        name := parts[len(parts)-1]
        if name in loaded_meshes{
            new_meshes[name] = {}
            continue
        }

        file_data, err := os.read_entire_file(path, context.allocator)
        defer delete_slice(file_data)
        if err != nil{
            fmt.println(err)
        }
        v, i := ge.load_azub(string(file_data))
        loaded_meshes[name] = ge.load_mesh(v, i)
        
        new_meshes[name] = {}
    }

    for name in loaded_meshes{
        
        if name not_in new_meshes{
            
            ge.unload_mesh(loaded_meshes[name])
            
            delete_key(&loaded_meshes, name)
            
        }
    }
    delete_map(new_meshes)
     
}

unload_models :: proc(){
    for name in loaded_meshes{
        ge.unload_mesh(loaded_meshes[name])
        delete_key(&loaded_meshes, name)
    }
}
get_mesh_id ::proc(name:string) -> d.MeshId{
    return loaded_meshes[name]
}