package physics
import d "../definition"
import mlin "core:math/linalg"
import "core:fmt"
physics_bodies : map[d.Entity]^PhysicsBody

start :: proc(){

}

end :: proc(){

}

tick :: proc(){
    //fmt.println(physics_bodies)
    for entity, body in physics_bodies{
        body.is_on_floor = false
        //fmt.println(entity)
        vel := (body.velocity*d.FIXED_UPDATE_INTERVAL)
        newPos := body.position+vel
        for entity2, body2 in physics_bodies{
            if body == body2{
                continue
            }
            isColliding, collision_normal, penetration := isOverlapping(body.collider,newPos, body2.collider,body2.position)
        
            if isColliding{
                if collision_normal.y > 0.8{
                    body.is_on_floor = true
                }
                // fmt.println(entity, " COLLIDED WITH ", entity2)
                // fmt.println("COLLISION NORMAL ", collision_normal)
                // fmt.println("COLLISION PEN ", penetration)
                vel = vel - (mlin.vector_dot(vel, collision_normal) * collision_normal)
                newNewPos := body.position + vel
                collide_again, newnorm, newpen := isOverlapping(body.collider,newNewPos, body2.collider,body2.position)
                if collide_again{
                    if newnorm.y > 0.8{
                        body.is_on_floor = true
                    }
                    //QUESTIONABLE MAYBE FIUX LATER
                    vel = vel - (mlin.vector_dot(vel, newnorm) * newnorm)
                }
            }
        }
        body.position += vel
        
    }
}

add_physics_body :: proc(entity : d.Entity, body : ^PhysicsBody){
    physics_bodies[entity] = body
}