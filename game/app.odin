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
    de.prof_init()
	defer de.prof_deinit()


    scene.add_scene("test", test_scene)
    engine.launch("test")
    de.terminate_tracker()
}


test_scene :: proc(){
    models : []string = {
        "res/model/anime_girl.obj",
        "res/model/revolver.obj",
        "res/model/ground.obj"
    }
    res.load_obj_models(models)
    textures :[]res.TextureInfo = {
        {"res/texture/pyramid.png",ge.TEXTURE_WRAP_MODE_REPEAT, ge.TEXTURE_FILTER_LINEAR},
        {"res/texture/pyramid_blue.png",ge.TEXTURE_WRAP_MODE_REPEAT, ge.TEXTURE_FILTER_LINEAR},
        {"res/texture/revolver_diffuse.png",ge.TEXTURE_WRAP_MODE_REPEAT, ge.TEXTURE_FILTER_LINEAR},
        {"res/texture/asphalt.png",ge.TEXTURE_WRAP_MODE_REPEAT, ge.TEXTURE_FILTER_LINEAR},
        {"res/texture/bg.png",ge.TEXTURE_WRAP_MODE_CLAMP_TO_EDGE, ge.TEXTURE_FILTER_NEAREST}
    }
    res.load_textures(textures)

    shaders : []string = {
        "res/shader/test_shader.glsl",
        "res/shader/bg.glsl"
    }
    res.load_shaders(shaders)
    shader := res.get_shader_id("test_shader.glsl")

    ge.create_background(res.get_texture_id("bg.png"), res.get_shader_id("bg.glsl"))


    mat := new(ge.Material)
        mat.shader = shader
        mat.uniforms = {
            "texture0"=ge.uniform(res.get_texture_id("pyramid_blue.png")),
            "camera_loc"=ge.uniform(&ge.camera_location),
            "uv_scale"=ge.uniform(1.0)
        }
    matid := ge.load_material(mat)
    for i in 0..<50{
        girl :d.Entity = entity.new_entity()
        trans.add(girl)
        trans.setScale(girl, {0.3, 0.3, 0.3})
        trans.setPosition(girl, {mrand.float32_range(-10, 10), 2.2, mrand.float32_range(-10, 10)})

        static_mesh.add(girl, "anime_girl.obj", matid)

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
    trans.setPosition(rev, {0.2, -0.4, -0.9})
    trans.setScale(rev, {0.5, 0.5, 0.5})


    rmat := new(ge.Material)
    rmat.shader = shader
    rmat.uniforms = {"texture0"=ge.uniform(res.get_texture_id("revolver_diffuse.png")),
                    "camera_loc"=ge.uniform(&ge.camera_location),
                    "uv_scale"=ge.uniform(1.0)}
    rmatid := ge.load_material(rmat)

    static_mesh.add(rev, "revolver.obj", rmatid)

    ps_data.Rev = rev

    gmat := new(ge.Material)
    gmat.shader = shader
    gmat.uniforms = {"texture0"=ge.uniform(res.get_texture_id("asphalt.png")),
                    "camera_loc"=ge.uniform(&ge.camera_location),
                    "uv_scale"=ge.uniform(500.0)}
    gmatid := ge.load_material(gmat)
    ground :d.Entity = entity.new_entity()
    trans.add(ground)
    trans.setScale(ground, {1000, 1, 1000})
    static_mesh.add(ground, "ground.obj", gmatid)

}

PlayerData :: struct{
    PlayerCamera : d.Entity,
    Rev : d.Entity,
    speed : f32
}




generate_player_script ::proc() -> ^script.Script{

    playerData := new(PlayerData)

    playerData.PlayerCamera=-1
    playerData.speed = 10
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

player_update ::proc(entity:d.Entity, data:rawptr, delta_time : f64){
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
        trans.addPosition(entity, forward*player_data.speed*f32(delta_time))
    }
    
    if w.keyboard["S"]{
        trans.addPosition(entity, -forward*player_data.speed*f32(delta_time))
    }
    
    if w.keyboard["A"]{
        trans.addPosition(entity, -right*player_data.speed*f32(delta_time))
    }
    if w.keyboard["D"]{
        trans.addPosition(entity, right*player_data.speed*f32(delta_time))
    }
    if w.keyboard["DOWN"]{
        scene.load_scene("test")
    }

    trans.rotateAround(entity, {0, 1, 0},-f32(w.cursor_difference.x)/1000)
    trans.rotateAround(player_data.PlayerCamera, {1, 0, 0}, -f32(w.cursor_difference.y)/1000)
    // trans.rotateAround(player_data.Rev, {1, 0, 0}, 0.01)
    // trans.setScale(player_data.Rev, m.pow_f32(m.sin(trans.getRotationEuler(player_data.Rev).x), 2))
}


player_fixed_update ::proc(entity:d.Entity, data:rawptr){

}
player_terminate ::proc(entity:d.Entity, data:rawptr){
}
