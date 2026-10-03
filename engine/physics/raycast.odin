package physics
import mlin "core:math/linalg"
import "core:fmt"

RaycastResult :: struct{
    colliding : bool
}

shootRaycast :: proc(rayStart : [3]f32,  collider : ^Collider, colliderPos : [3]f32) -> RaycastResult {
    


    penetration :f32 = 99999999
    collision_normal : [3]f32 = {0, 0, 0}
    for face in collider.faces{
        //implement möller trumbore algorithm
    }

    return RaycastResult{
        true
    }
}