package entity
import transform "comp/transform"
import static_mesh "comp/static_mesh"
import script "comp/script"
import camera "comp/camera"
import d "../definition"

next_entity_id : d.Entity = 0



start_components : [dynamic]proc()
update_components : [dynamic]proc()
fixed_update_components : [dynamic]proc()
terminate_components : [dynamic]proc()

initialize_components ::proc(){
    append(&start_components, transform.start)
    append(&update_components, transform.update)
    append(&fixed_update_components, transform.fixed_update)
    append(&terminate_components, transform.terminate)

    append(&start_components, static_mesh.start)
    append(&update_components, static_mesh.update)
    append(&fixed_update_components, static_mesh.fixed_update)
    append(&terminate_components, static_mesh.terminate)

    append(&start_components, script.start)
    append(&update_components, script.update)
    append(&fixed_update_components, script.fixed_update)
    append(&terminate_components, script.terminate)

    append(&start_components, camera.start)
    append(&update_components, camera.update)
    append(&fixed_update_components, camera.fixed_update)
    append(&terminate_components, camera.terminate)

}


new_entity :: proc() -> d.Entity{

    defer next_entity_id += 1
    return next_entity_id
}

run_start_components :: proc(){
    for proce in start_components{
        proce()
    }
}

run_update_components :: proc(){
    for proce in update_components{
        proce()
    }
}

run_fixed_update_components :: proc(){
    for proce in fixed_update_components{
        proce()
    }
}

run_terminate_components :: proc(){
    for proce in terminate_components{
        proce()
    }
}