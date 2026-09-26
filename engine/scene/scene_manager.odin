package scene

import entity "../entity"

Scene :: proc()

scenes : map[string]Scene

current_scene : string

add_scene :: proc(name : string, scene_proc : Scene){
    scenes[name] = scene_proc
}



load_scene :: proc(name : string){
    entity.run_terminate_components()
    current_scene = name
    scenes[name]()
}