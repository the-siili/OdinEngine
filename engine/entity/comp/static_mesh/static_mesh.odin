#+feature dynamic-literals
package static_mesh

import "core:fmt"
import d "../../../definition"
import transform "../transform"
import ge "../../../graphics"
import mlin "core:math/linalg"
import res "../../../resource"
import de "../../../debugger"
StaticMesh :: struct{
    material : d.MaterialId,
    render_object_id : d.RenderObjectId
}



static_meshes : map[d.Entity]^StaticMesh = {}
update_stack : [dynamic]d.Entity


start :: proc() {

}
update :: proc(delta_time : f64) {
    de.prof_frame_part()
    for entity in static_meshes{
        fmt.println("RIGHT BEFORE RENDERING: ", transform.getGlobalRotationEuler(entity))
        ge.set_render_object_transform(static_meshes[entity].render_object_id, transform.getGlobalPosition(entity), transform.getGlobalRotationEuler(entity), transform.getGlobalScale(entity))

    }
}
fixed_update :: proc() {

}
terminate :: proc() {
    for entity in static_meshes{
        ge.remove_render_object(static_meshes[entity].render_object_id)
        free(static_meshes[entity])
    }
    clear(&static_meshes)
}


add :: proc(entity : d.Entity, mesh_name : string, mat : d.MaterialId) {
    stat_mesh := new(StaticMesh)
    stat_mesh.material = mat
    stat_mesh.render_object_id =ge.create_render_object(res.get_mesh_id(mesh_name), mat, transform.getGlobalPosition(entity), transform.getGlobalRotationEuler(entity), transform.getGlobalScale(entity))

    static_meshes[entity] = stat_mesh

}