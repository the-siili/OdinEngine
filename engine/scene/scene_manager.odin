package scene

import entity "../entity"
import "core:fmt"
import ge "../graphics"
import de "../debugger"
Scene :: proc()

scenes : map[string]Scene

current_scene : string
next_scene : string
add_scene :: proc(name : string, scene_proc : Scene){
    scenes[name] = scene_proc
}



load_scene :: proc(name : string){
    next_scene = name
}

move_to_next_scene :: proc(){
    //leak size 2532
    if next_scene == ""{
        return
    }
    
    entity.run_terminate_components()
    
    ge.remove_all_render_objects()
    
    de.print_unfreed_data("before remove render ")
    scenes[next_scene]()
    de.print_unfreed_data("after remove render ")
    current_scene = next_scene
    next_scene = ""
    
}