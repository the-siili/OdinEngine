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
package main

import    "vendor:glfw"
import gl "vendor:OpenGL"
import    "core:time"
import m  "core:math"
import mrand  "core:math/rand"
import    "core:fmt"
import    "core:os"
import    "base:runtime"



main :: proc() {

    intialize_window({1280, 800})
    vertices : [] f32 = {
        // coords  ; colors
            -1, -1, -1,
        +1, -1, -1,
        -1, +1, -1,
        +1, +1, -1,

        -1, -1, +1,
        +1, -1, +1,
        -1, +1, +1,
        +1, +1, +1,

        -1, -1, -1,
        -1, +1, -1,
        -1, -1, +1,
        -1, +1, +1,

        +1, -1, -1,
        +1, +1, -1,
        +1, -1, +1,
        +1, +1, +1,

        -1, -1, -1,
        +1, -1, -1,
        -1, -1, +1,
        +1, -1, +1,

        -1, +1, -1,
        +1, +1, -1,
        -1, +1, +1,
        +1, +1, +1,
    }

    index_array : [] u32
    index_array = {
        0,  1,   2,  1,  2,  3, // Face 1
        4,  5,   6,  5,  6,  7, // Face 2
        8,  9,  10,  9, 10, 11, // Face 3
        12, 13, 14, 13, 14, 15, // Face 4
        16, 17, 18, 17, 18, 19, // Face 5
        20, 21, 22, 21, 22, 23, // Face 6
    }

    vertices1 : [] f32 = {
        0, 1, 0,
        0, 0, 1,
        -1, 0, -1,
        1, 0, -1
    }

    index_array1 : [] u32
    index_array1 = {
        0, 1, 2,
        0, 1, 3,
        0, 2, 3,
        1, 2, 3
    }



    vertex_shader   := string(#load("vertex.glsl"  ))
    fragment_shader := string(#load("fragment.glsl"))

    vertex_shader1   := string(#load("vertex1.glsl"  ))
    fragment_shader1 := string(#load("fragment1.glsl"))

    shader := load_shader(vertex_shader, fragment_shader)
    shader1 := load_shader(vertex_shader1, fragment_shader1)


    cube := load_mesh(vertices1, index_array1)
    render_mesh(cube, {0.5, 0, 3}, shader)
    render_mesh(cube, {-0.5, 0.5, -3}, shader)

    for i in 0..<300{
        sha := shader
        if i % 2 == 0{
            sha = shader1
        }
        render_mesh(cube, {mrand.float32_range(-40, 40), mrand.float32_range(-40, 40), -mrand.float32_range(-40, 40)}, sha)
    }

    for !glfw.WindowShouldClose(window) {
        glfw.PollEvents()

        if keyboard["A"]{
            camera_location.x -= 0.1
        }
        if keyboard["D"]{
            camera_location.x += 0.1
        }
        if keyboard["S"]{
            camera_location.z += 0.1
        }
        if keyboard["W"]{
            camera_location.z -= 0.1
        }
        if keyboard["LEFT"]{
            camera_rotation.y += 0.01
        }
        if keyboard["RIGHT"]{
            camera_rotation.y -= 0.01
        }
        if keyboard["UP"]{
            camera_rotation.x += 0.01
        }
        if keyboard["DOWN"]{
            camera_rotation.x -= 0.01
        }

        camera_rotation.y -= f32(cursor_difference.x / 1000)
        camera_rotation.x -= f32(cursor_difference.y / 1000)
        if camera_rotation.x > m.to_radians_f32(90){
            camera_rotation.x = m.to_radians_f32(90)
        }
        if camera_rotation.x < m.to_radians_f32(-90){
            camera_rotation.x = m.to_radians_f32(-90)
        }

        render_screen()
    }
}