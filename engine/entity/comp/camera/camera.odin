#+feature dynamic-literals
package camera

import "core:fmt"
import d "../../../definition"
import ge "../../../graphics"
import trans "../transform"
import m "core:math"
import de "../../../debugger"
Camera :: struct{
    pos_offset: [3]f32,
    rot_offset: [3]f32,
    fov: f32
}

CurrentCamera : d.Entity

cameras : map[d.Entity]^Camera = {}



start :: proc() {
}
update :: proc(delta_time : f64) {

}

late_update :: proc(delta_time : f64){
    de.prof_frame_part()
    ge.camera_location = trans.getGlobalPosition(CurrentCamera)
    ge.camera_rotation = trans.getGlobalRotationEuler(CurrentCamera)
}

fixed_update :: proc() {
}
terminate :: proc() {
    for entity in cameras{
        free(cameras[entity])
    }
    clear(&cameras)
}


add :: proc(entity : d.Entity) {
    camera := new(Camera)
    camera.fov = 65
    camera.pos_offset = {0, 0, 0}
    camera.rot_offset = {0, 0, 0}

    cameras[entity] = camera
    if len(cameras) == 1{
        CurrentCamera = entity
    }
}

getRotOffset :: proc(entity : d.Entity) -> [3]f32{

    return cameras[entity].rot_offset
}

setRotOffset :: proc(entity : d.Entity, new_offset : [3]f32){

    cameras[entity].rot_offset = new_offset
}
addRotOffset :: proc(entity : d.Entity, added_rotation : [3]f32, clamp_to_90:bool){

    cameras[entity].rot_offset += added_rotation
    if m.to_degrees_f32(cameras[entity].rot_offset.x) > 90{
        cameras[entity].rot_offset.x = m.to_radians_f32(90)
    }
    else if m.to_degrees_f32(cameras[entity].rot_offset.x) < -90{
        cameras[entity].rot_offset.x = m.to_radians_f32(-90)
    }
}


getPosOffset :: proc(entity : d.Entity) -> [3]f32{

    return cameras[entity].pos_offset
}

setPosOffset :: proc(entity : d.Entity, new_offset : [3]f32){

    cameras[entity].pos_offset = new_offset
}