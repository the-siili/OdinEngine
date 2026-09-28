// An elementary program in Odin which creates a colored cube
// which rotates over time.
//
// Created by Benjamin Thompson. Available at:
// https://github.com/bg-thompson/OpenGL-Tutorials-In-Odin
// Last updated: 2024.09.15
//
// To compile and run the program with optimizations, use the command
//
//     odin run Rotating-Cube -o:speed
//
// Created for educational purposes. Used verbatim, it is probably
// unsuitable for production code.
#+feature dynamic-literals
package engine

import  ge"graphics"
import w "window"
import    "vendor:glfw"
import gl "vendor:OpenGL"
import    "core:image"
import  q "core:image/qoi"
import    "core:time"
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

launch :: proc(scene_name : string) {

    

    
    CurrentWindow = w.intialize_window({1280, 800})

    entity.initialize_components()

    scene.load_scene(scene_name)
    scene.move_to_next_scene()

    entity.run_start_components()
    defer entity.run_terminate_components()

    for !glfw.WindowShouldClose(CurrentWindow) {
       // de.print_unfreed_data(" before frame")
        glfw.PollEvents()
        w.update_mouse_position()
        defer w.reset_mouse_position()
        entity.run_update_components()
        ge.render_screen(CurrentWindow)
        scene.move_to_next_scene()
        //de.print_unfreed_data(" after frame")
    }
    ge.remove_all_render_objects()
    //entity.clean_entity_manager()
}