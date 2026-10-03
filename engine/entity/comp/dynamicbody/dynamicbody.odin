#+feature dynamic-literals
package dynamicbody

import "core:fmt"
import d "../../../definition"
import transform "../transform"
import ge "../../../graphics"
import mlin "core:math/linalg"
import res "../../../resource"
import de "../../../debugger"
import phy "../../../physics"

StaticMesh :: struct{
    material : d.MaterialId,
    render_object_id : d.RenderObjectId
}

dynamic_bodies : map[d.Entity]^phy.PhysicsBody

fixed_update :: proc(){
    for entity, body in dynamic_bodies{
        transform.transforms[entity].local_position = body.position
    }

}


add :: proc(entity : d.Entity, pos : [3]f32, w : f32, h:f32, d:f32) {
    hw := w
    hh := h
    hd := d
    body := new(phy.PhysicsBody)
    collider := new(phy.Collider)
    collider.vertecies = {
        {-0.5*hw, -0.5*hh, -0.5*hd},
        {-0.5*hw,-0.5*hh,0.5*hd},
        {-0.5*hw,0.5*hh,-0.5*hd},
        {-0.5*hw, 0.5*hh, 0.5*hd},
        {0.5*hw, -0.5*hh, -0.5*hd},
        {0.5*hw, -0.5*hh, 0.5*hd},
        {0.5*hw, 0.5*hh, -0.5*hd},
        {0.5*hw, 0.5*hh, 0.5*hd}
    }
    collider.faces = {
        {0, 1, 2, 3},//l
        {4, 5, 6, 7},//r
        {0, 1, 4, 5},//b
        {2, 3, 6, 7},//t
        {0, 2, 4, 6},//f
        {1, 3, 5, 7}//back
    }

    body.collider = collider
    body.position = pos
    body.velocity = {0, 0, 0}
    body.drag = 0
    phy.add_physics_body(entity, body)
    dynamic_bodies[entity] = body
}


setVelocity :: proc(entity : d.Entity, new_velocity : [3]f32){
    dynamic_bodies[entity].velocity = new_velocity
}
getVelocity :: proc(entity : d.Entity) -> [3]f32{
    return dynamic_bodies[entity].velocity
}

setVelocityY :: proc(entity : d.Entity, new_velocity : f32){
    dynamic_bodies[entity].velocity.y = new_velocity
}

addVelocityY :: proc(entity : d.Entity, added_velocity : f32){
    dynamic_bodies[entity].velocity.y += added_velocity
}
