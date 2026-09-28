#+feature dynamic-literals
package transform

import "core:fmt"
import d "../../../definition"
import m "core:math"
import mlin "core:math/linalg"
import de "../../../debugger"


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
    
}
late_update :: proc() {
    
    // for entity in transforms{
    //     if transforms[entity].parent == -1{
    //         continue
    //     }
    //     parent := transforms[entity].parent
    //     child_pos := transforms[entity].local_position
    //     parent_pos := transforms[parent].global_position
    //     child_rot := transforms[entity].local_rotation
    //     parent_rot := transforms[parent].global_rotation

    //     rotated_pos := mlin.quaternion128_mul_vector3(parent_rot, child_pos)
    //     transforms[entity].global_position = parent_pos + rotated_pos
    //     transforms[entity].global_rotation = parent_rot * child_rot
    // }
    
}

stack :[dynamic]d.Entity = {}

update :: proc() {
    for entity in transforms{
        if transforms[entity].parent == -1{
            append(&stack, entity)
        }
    }
  
    for entity in stack{

        if transforms[entity].parent != -1{
            parent := transforms[entity].parent
            child_pos := transforms[entity].local_position
            parent_pos := transforms[parent].global_position
            child_rot := transforms[entity].local_rotation
            parent_rot := transforms[parent].global_rotation

            transforms[entity].global_scale =  transforms[entity].local_scale * transforms[parent].global_scale

            rotated_pos := mlin.quaternion128_mul_vector3(parent_rot, child_pos)
            transforms[entity].global_position = (parent_pos + rotated_pos) * transforms[parent].global_scale
            transforms[entity].global_rotation = parent_rot * child_rot

            
        }
        else{
            transforms[entity].global_position = transforms[entity].local_position
            transforms[entity].global_rotation = transforms[entity].local_rotation
            transforms[entity].global_scale =  transforms[entity].local_scale
        }

        for child in transforms[entity].children{
            append(&stack, child)
        }
        
    }
    

     clear(&stack)
}

fixed_update :: proc() {
}
terminate :: proc() {
    for entity in transforms{
        delete_dynamic_array(transforms[entity].children)
        free(transforms[entity])
    }
    clear(&transforms)
}


add :: proc(entity : d.Entity, parent : d.Entity = -1) {
    transform := new(Transform)
    
    transform.global_position={0, 0, 0}
    transform.global_rotation=quaternion(x=0, y=0, z=0, w=1)
    transform.global_scale={1, 1, 1}
    transform.local_position={0, 0, 0}
    transform.local_rotation=quaternion(x=0, y=0, z=0, w=1)
    transform.local_scale={1, 1, 1}
    transform.children={}
    transform.parent=parent

    if parent != -1{
        append(&transforms[parent].children, entity)
    }

    transforms[entity] = transform
}

setParent :: proc(entity : d.Entity, parent : d.Entity){
    transforms[entity].parent = parent
    append(&transforms[parent].children, entity)
}


getGlobalPosition :: proc(entity : d.Entity) -> [3]f32{

    return transforms[entity].global_position
}

getPosition :: proc(entity : d.Entity) -> [3]f32{

    return transforms[entity].local_position
}
setPosition :: proc(entity : d.Entity, new_position : [3]f32){

    transforms[entity].local_position = new_position
}

addPosition :: proc(entity : d.Entity, added_position : [3]f32){

    transforms[entity].local_position += added_position
}

getGlobalRotation :: proc(entity : d.Entity) -> quaternion128{

    return transforms[entity].global_rotation
}

getGlobalRotationEuler :: proc(entity : d.Entity) -> [3]f32{
    rx, ry, rz := mlin.euler_angles_from_quaternion_f32(transforms[entity].global_rotation, mlin.Euler_Angle_Order.XYZ)
    return  [3]f32{rx, ry, rz}
}

getRotation :: proc(entity : d.Entity) -> quaternion128{

    return transforms[entity].local_rotation
}
getRotationEuler :: proc(entity : d.Entity) -> [3]f32{
    rx, ry, rz := mlin.euler_angles_from_quaternion_f32(transforms[entity].local_rotation, mlin.Euler_Angle_Order.XYZ)
    return  [3]f32{rx, ry, rz}
}

setRotation :: proc(entity : d.Entity, new_rotation : quaternion128){

    transforms[entity].local_rotation = new_rotation
}
addRotation :: proc(entity : d.Entity, added_rotation : quaternion128){

    transforms[entity].local_rotation = transforms[entity].local_rotation * added_rotation
}

rotateAround :: proc(entity : d.Entity, axis:[3]f32, amount:f32){

    transforms[entity].local_rotation = transforms[entity].local_rotation * mlin.quaternion_angle_axis_f32(amount, axis)
}

getGlobalScale :: proc(entity : d.Entity) -> [3]f32{

    return transforms[entity].global_scale
}

getScale :: proc(entity : d.Entity) -> [3]f32{

    return transforms[entity].local_scale
}
setScale :: proc(entity : d.Entity, new_scale : [3]f32){

    transforms[entity].local_scale = new_scale
}

addScale :: proc(entity : d.Entity, added_scale : [3]f32){

    transforms[entity].local_scale += added_scale
}
