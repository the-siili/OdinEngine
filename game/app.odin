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
import res "../engine/resource"
import de "../engine/debugger"
CurrentWindow : glfw.WindowHandle

main :: proc() {
    context.allocator = de.initialize_tracker()
    de.print_unfreed_data(" before all")
    scene.add_scene("test", test_scene)
    scene.add_scene("test_scene1", test_scene1)
    engine.launch("test")
    de.print_unfreed_data(" after all")
    de.terminate_tracker()
}


test_scene :: proc(){
    models : []string = {
        "res/model/anime_girl.obj",
        "res/model/revolver.obj"
    }
    res.load_obj_models(models)
    textures :[]string = {
        "res/texture/pyramid.png",
        "res/texture/pyramid_blue.png",
        "res/texture/revolver_diffuse.png"
    }
    res.load_textures(textures)

    shaders : []string = {
        "res/shader/test_shader.glsl"
    }
    res.load_shaders(shaders)
    shader := res.get_shader_id("test_shader.glsl")

    mat := new(ge.Material)
        mat.shader = shader
        mat.uniforms = {
            "texture0"=ge.uniform(res.get_texture_id("pyramid_blue.png")),
            "camera_loc"=ge.uniform(ge.camera_location)
        }

    for i in 0..<500{
        girl :d.Entity = entity.new_entity()
        trans.add(girl)
        trans.setPosition(girl, {mrand.float32_range(-100, 100), 3, mrand.float32_range(-100, 100)})

        static_mesh.add(girl, "anime_girl.obj", mat)

    }




    player :d.Entity = entity.new_entity()
    trans.add(player )
    
    trans.setPosition(player, {0, 0.0, 0})
    fmt.println("BRUUUUHH")
    playerScript := generate_player_script()
    
    script.add(player, playerScript)
    
    cam : d.Entity = entity.new_entity()
    trans.add(cam, player)
    camera.add(cam)
    trans.setPosition(cam, {0, 1.7, 0})
    ps_data := cast(^PlayerData)playerScript.data
    ps_data.PlayerCamera = cam

    rev :d.Entity = entity.new_entity()
    trans.add(rev, cam)
    trans.setPosition(rev, {0.2, -0.2, -0.9})
    trans.setScale(rev, {1, 1, 1})
    rmat := new(ge.Material)
    rmat.shader = shader
    rmat.uniforms = {"texture0"=ge.uniform(res.get_texture_id("revolver_diffuse.png")),
                    "camera_loc"=ge.uniform(ge.camera_location), 
                    "loc"=ge.uniform(trans.getPosition(rev))}
    static_mesh.add(rev, "revolver.obj", rmat)

    ps_data.Rev = rev

    
}

test_scene1:: proc(){
    models : []string = {
        "res/model/revolver.obj"
    }
    res.load_obj_models(models)
    textures :[]string = {
       // "res/texture/pyramid_blue.png",
        "res/texture/revolver_diffuse.png"
    }
    res.load_textures(textures)

    shaders : []string = {
        "res/shader/test_shader.glsl"
    }
    res.load_shaders(shaders)
    shader := res.get_shader_id("test_shader.glsl")
    

    player :d.Entity = entity.new_entity()
    trans.add(player )
    trans.setPosition(player, {0, 0.0, 0})
    //camera.setPosOffset(player, [3]f32{0, 1, 0})
    playerScript := generate_player_script()
    script.add(player, playerScript)

    cam : d.Entity = entity.new_entity()
    trans.add(cam, player)
    camera.add(cam)
    trans.setPosition(cam, {0, 1.7, 0})
    ps_data := cast(^PlayerData)playerScript.data
    ps_data.PlayerCamera = cam

    rev :d.Entity = entity.new_entity()
    trans.add(rev, cam)
    trans.setPosition(rev, {0.2, -0.2, -0.9})
    trans.setScale(rev, {1, 1, 1})
    rmat := new(ge.Material)
    rmat.shader = shader
    rmat.uniforms = {"texture0"=ge.uniform(res.get_texture_id("revolver_diffuse.png")),
                "camera_loc"=ge.uniform(ge.camera_location), 
                "loc"=ge.uniform(trans.getPosition(rev))}
    fmt.println(rmat)
    static_mesh.add(rev, "revolver.obj", rmat)

    ps_data.Rev = rev
}


PlayerData :: struct{
    PlayerCamera : d.Entity,
    Rev : d.Entity,
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
    if w.keyboard["DOWN"]{
        scene.load_scene("test")
    }

    trans.rotateAround(entity, {0, 1, 0},-f32(w.cursor_difference.x)/1000)
    trans.rotateAround(player_data.PlayerCamera, {1, 0, 0}, -f32(w.cursor_difference.y)/1000)
    trans.rotateAround(player_data.Rev, {1, 0, 0}, 0.01)
    trans.setScale(player_data.Rev, m.pow_f32(m.sin(trans.getRotationEuler(player_data.Rev).x), 2))
}


player_fixed_update ::proc(entity:d.Entity, data:rawptr){
    if w.keyboard["W"]{
        trans.setPosition(entity, trans.getPosition(entity) + [3]f32{0, 0, 0.1})
    }
}
player_terminate ::proc(entity:d.Entity, data:rawptr){
}
