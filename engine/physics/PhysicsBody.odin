package physics
import d "../definition"


PhysicsBody :: struct{
    position :[3]f32,
    velocity : [3]f32,
    drag : f32,
    collider : Collider
}

setVelocity :: proc(entity : d.Entity, new_velocity : [3]f32){
    body := physics_bodies[entity]
    body.velocity = new_velocity
    physics_bodies[entity] = body
}