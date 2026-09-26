#+feature dynamic-literals
package transform

import "core:fmt"
import d "../../../definition"
import m "core:math"
import mling "core:math/linalg"


Transform :: struct{
    global_position : [3]f32,
    global_rotation : quaternion128,
    global_scale : [3]f32,
    local_position : [3]f32,
    local_rotation : quaternion128,
    local_scale : [3]f32,
    children : [dynamic]d.Entity,
    parent : d.Entity
}



transforms : map[d.Entity]^Transform = {}



start :: proc() {
    
    for entity in transforms{
        entity_pos := transforms[entity].global_position
        for child in transforms[entity].children{
            child_local_pos := transforms[child].local_position
            transforms[child].global_position = [3]f32{entity_pos.x+child_local_pos.x, entity_pos.y+child_local_pos.y, entity_pos.z+child_local_pos.z,}
        }
    }
}
update :: proc() {
    
    for entity in transforms{
        if transforms[entity].parent == -1{
            continue
        }
        parent := transforms[entity].parent
        child_pos := transforms[entity].local_position
        parent_pos := transforms[parent].global_position
        child_rot := transforms[entity].local_rotation
        parent_rot := transforms[parent].global_rotation

        rotated_pos := mling.quaternion128_mul_vector3(parent_rot, child_pos)
        transforms[entity].global_position = parent_pos + rotated_pos
        transforms[entity].global_rotation = parent_rot * child_rot
    }
    
}
fixed_update :: proc() {
}
terminate :: proc() {
    for entity in transforms{
        free(transforms[entity])
        delete_key(&transforms, entity)
    }
    clear(&transforms)
}


add :: proc(entity : d.Entity) {
    transform := new(Transform)
    
    transform.global_position={0, 0, 0}
    transform.global_rotation=quaternion(x=0, y=0, z=0, w=1)
    transform.global_scale={1, 1, 1}
    transform.local_position={0, 0, 0}
    transform.local_rotation=quaternion(x=0, y=0, z=0, w=1)
    transform.local_scale={1, 1, 1}
    transform.children={}
    transform.parent=-1

    transforms[entity] = transform
}

setParent :: proc(entity : d.Entity, parent : d.Entity){
    transforms[entity].parent = parent
    append(&transforms[parent].children, entity)
}


getPosition :: proc(entity : d.Entity) -> [3]f32{

    return transforms[entity].global_position
}
setPosition :: proc(entity : d.Entity, new_position : [3]f32){

    transforms[entity].global_position = new_position
}

addPosition :: proc(entity : d.Entity, added_position : [3]f32){

    transforms[entity].global_position += added_position
}

getLocalPosition :: proc(entity : d.Entity) -> [3]f32{

    return transforms[entity].local_position
}
setLocalPosition :: proc(entity : d.Entity, new_position : [3]f32){

    transforms[entity].local_position = new_position
}

addLocalPosition :: proc(entity : d.Entity, added_position : [3]f32){

    transforms[entity].local_position += added_position
}

getRotation :: proc(entity : d.Entity) -> quaternion128{

    return transforms[entity].global_rotation
}

getRotationEuler :: proc(entity : d.Entity) -> [3]f32{
    rx, ry, rz := mling.euler_angles_from_quaternion_f32(transforms[entity].global_rotation, mling.Euler_Angle_Order.XYZ)
    return  [3]f32{rx, ry, rz}
}

setRotation :: proc(entity : d.Entity, new_rotation : quaternion128){

    transforms[entity].global_rotation = new_rotation
}
addRotation :: proc(entity : d.Entity, added_rotation : quaternion128){

    transforms[entity].global_rotation = transforms[entity].global_rotation * added_rotation
}

getLocalRotation :: proc(entity : d.Entity) -> quaternion128{

    return transforms[entity].local_rotation
}
setLocalRotation :: proc(entity : d.Entity, new_rotation : quaternion128){

    transforms[entity].local_rotation = new_rotation
}
addLocalRotation :: proc(entity : d.Entity, added_rotation : quaternion128){

    transforms[entity].local_rotation = transforms[entity].local_rotation * added_rotation
}


