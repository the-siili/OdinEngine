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

import  ge"../engine/graphics"
import w  "../engine/window"
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
import mem "core:mem"
import mlin "core:math/linalg"
import entity "../engine/entity"
import engine "../engine"
import d "../engine/definition"
import scene "../engine/scene"
import trans "../engine/entity/comp/transform"
import static_mesh "../engine/entity/comp/static_mesh"
import script "../engine/entity/comp/script"
import camera "../engine/entity/comp/camera"
CurrentWindow : glfw.WindowHandle

main :: proc() {

    scene.add_scene("test", test_scene)
    engine.launch("test")
}


test_scene :: proc(){

    anime_girl_str := string(#load("res/model/anime_girl.obj"))
    anime_girl_vert, anime_girl_ind := ge.load_obj(anime_girl_str)
    anime_girl_mesh := ge.load_mesh(anime_girl_vert, anime_girl_ind)

    rev_str := string(#load("res/model/revolver.obj"))
    rev_vert, rev_ind := ge.load_obj(rev_str)
    rev_mesh := ge.load_mesh(rev_vert, rev_ind)


    shader := ge.load_shader(string(#load("res/shader/vertex1.glsl")), string(#load("res/shader/fragment1.glsl"))) 
    
    texture1_file_bytes := #load("res/texture/pyramid.png")
    texture2_file_bytes := #load("res/texture/pyramid_blue.png")
    tex1 := ge.load_texture(texture1_file_bytes)
    tex2 := ge.load_texture(texture2_file_bytes)

    revtex2_file_bytes := #load("res/texture/revolver_diffuse.png")
    revtex := ge.load_texture(revtex2_file_bytes)


    girl :d.Entity = entity.new_entity()
    trans.add(girl)

    mat := new(ge.Material)
    mat.shader = shader
    mat.textures = {"texture0"=tex1, "texture1"=tex2}
    mat.vec3s = {"camera_loc"=ge.camera_location, "loc"=trans.getPosition(girl)}

    static_mesh.add(girl, anime_girl_mesh, mat)




    player :d.Entity = entity.new_entity()
    trans.add(player )
    //camera.setPosOffset(player, [3]f32{0, 1, 0})
    playerScript := generate_player_script()
    script.add(player, playerScript)

    cam : d.Entity = entity.new_entity()
    trans.add(cam)
    camera.add(cam)
    trans.setParent(cam, player)
    trans.setLocalPosition(cam, {0, 0.5, 0})
    ps_data := cast(^PlayerData)playerScript.data
    ps_data.PlayerCamera = cam

    rev :d.Entity = entity.new_entity()
    trans.add(rev)
    trans.setParent(rev, cam)
    trans.setLocalPosition(rev, {0.2, -0.2, -0.9})
    rmat := new(ge.Material)
    rmat.shader = shader
    rmat.textures = {"texture0"=revtex, "texture1"=revtex}
    rmat.vec3s = {"camera_loc"=ge.camera_location, "loc"=trans.getPosition(rev)}

    static_mesh.add(rev, rev_mesh, rmat)
}


PlayerData :: struct{
    PlayerCamera : d.Entity
}




generate_player_script ::proc() -> ^script.Script{

    playerData := new(PlayerData)

    playerData.PlayerCamera=-1

    playerBeh := new(script.Script)
    playerBeh.start=player_start
    playerBeh.update=player_update
    playerBeh.fixed_update=player_fixed_update
    playerBeh.terminate=player_terminate
    playerBeh.data=playerData

    return playerBeh
}


player_start ::proc(entity:d.Entity, data:rawptr){

    player_data := cast(^PlayerData)data


}

player_update ::proc(entity:d.Entity, data:rawptr){

    player_data := cast(^PlayerData)data
    rotation := trans.getRotation(entity)
    
    right := mlin.quaternion128_mul_vector3(
        rotation,
        [3]f32{1, 0, 0},
    )

    forward := mlin.quaternion128_mul_vector3(
        rotation,
        [3]f32{0, 0, -1},
    )
    if w.keyboard["W"]{
        trans.addPosition(entity, forward*0.1)
    }
    
    if w.keyboard["S"]{
        trans.addPosition(entity, -forward*0.1)
    }
    
    if w.keyboard["A"]{
        trans.addPosition(entity, -right*0.1)
    }
    if w.keyboard["D"]{
        trans.addPosition(entity, right*0.1)
    }

    trans.addRotation(entity, mlin.quaternion_angle_axis_f32(-f32(w.cursor_difference.x)/1000, {0, 1, 0}))
    trans.addLocalRotation(player_data.PlayerCamera, mlin.quaternion_angle_axis_f32(-f32(w.cursor_difference.y)/1000, {1, 0, 0}))

    fmt.println(trans.getRotation(entity))

}


player_fixed_update ::proc(entity:d.Entity, data:rawptr){
    if w.keyboard["W"]{
        trans.setPosition(entity, trans.getPosition(entity) + [3]f32{0, 0, 0.1})
    }
}
player_terminate ::proc(entity:d.Entity, data:rawptr){

}
