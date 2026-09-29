#+feature dynamic-literals
package engine

import  ge"graphics"
import w "window"
import    "vendor:glfw"
import gl "vendor:OpenGL"
import "core:time"
import    "core:image"
import  q "core:image/qoi"
import m  "core:math"
import mrand  "core:math/rand"
import    "core:fmt"
import    "core:os"
import    "base:runtime"
import "core:mem"
import de "debugger"
import scene "scene"
import entity "entity"

CurrentWindow : glfw.WindowHandle

delta_tick : time.Tick
delta_time : f64

launch :: proc(scene_name : string) {

    
    delta_tick := time.tick_now()
    
    CurrentWindow = w.initialize_window({1280, 800})

    entity.initialize_components()

    scene.load_scene(scene_name)
    scene.move_to_next_scene()

    entity.run_start_components()
    defer entity.run_terminate_components()

    for !glfw.WindowShouldClose(CurrentWindow) {
        delta_time = time.duration_milliseconds(time.tick_since(delta_tick))/1000.0
        delta_tick = time.tick_now()
        de.prof_frame()
       // de.print_unfreed_data(" before frame")
       
        w.read_input()
        defer w.clear_input()
        entity.run_update_components(delta_time)
        ge.render_screen(CurrentWindow)
        scene.move_to_next_scene()
        //de.print_unfreed_data(" after frame")
    }
    ge.remove_all_render_objects()
    //entity.clean_entity_manager()
}

quit :: proc(){
    scene.unload_current_scene()
    os.exit(0)
}