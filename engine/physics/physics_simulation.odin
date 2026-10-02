package physics
import d "../definition"

physics_bodies : map[d.Entity]PhysicsBody

tick_rate := 60

start :: proc(){

}

end :: proc(){

}

tick :: proc(){

    for entity, &body in physics_bodies{
        newPos := body.position+(body.velocity/60.0)
        for entity2, body2 in physics_bodies{
            if entity == entity2{
                continue
            }
            if isOverlapping(body.collider,newPos, body2.collider,body2.position){
                return
            }
        }

        body.position = newPos
    }
}

add_physics_body :: proc(entity : d.Entity, body : PhysicsBody){
    physics_bodies[entity] = body
}