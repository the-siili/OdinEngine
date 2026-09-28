#+feature dynamic-literals
package static_mesh

import "core:fmt"
import d "../../../definition"
import transform "../transform"
import ge "../../../graphics"
import mlin "core:math/linalg"
import res "../../../resource"

StaticMesh :: struct{
    material : ^ge.Material,
    render_object_id : d.RenderObjectId
}



static_meshes : map[d.Entity]^StaticMesh = {}



start :: proc() {

}
update :: proc() {
    for entity in static_meshes{
        ge.set_render_object_position(static_meshes[entity].render_object_id, transform.getGlobalPosition(entity))
        rx, ry, rz := mlin.euler_angles_from_quaternion_f32(transform.getGlobalRotation(entity), mlin.Euler_Angle_Order.XYZ)
        ge.set_render_object_rotation(static_meshes[entity].render_object_id, [3]f32{rx, ry, rz})
        ge.set_render_object_scale(static_meshes[entity].render_object_id, transform.getGlobalScale(entity))
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


add :: proc(entity : d.Entity, mesh_name : string, mat : ^ge.Material) {
    stat_mesh := new(StaticMesh)
    stat_mesh.material = mat
    stat_mesh.render_object_id =ge.create_render_object(res.get_mesh_id(mesh_name), mat, transform.getGlobalPosition(entity), transform.getGlobalRotationEuler(entity), transform.getGlobalScale(entity))

    static_meshes[entity] = stat_mesh

}