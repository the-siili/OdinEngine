#+feature dynamic-literals
package static_mesh

import "core:fmt"
import d "../../../definition"
import transform "../transform"
import ge "../../../graphics"
import mlin "core:math/linalg"

StaticMesh :: struct{
    material : ^ge.Material,
    render_object_id : d.RenderObjectId
}



static_meshes : map[d.Entity]^StaticMesh = {}



start :: proc() {

}
update :: proc() {
    for entity in static_meshes{
        ge.render_objects[static_meshes[entity].render_object_id].location = transform.getPosition(entity)
        rx, ry, rz := mlin.euler_angles_from_quaternion_f32(transform.getRotation(entity), mlin.Euler_Angle_Order.XYZ)
        ge.render_objects[static_meshes[entity].render_object_id].rotation = [3]f32{rx, ry, rz}
    }
}
fixed_update :: proc() {

}
terminate :: proc() {
    for entity in static_meshes{
        free(static_meshes[entity])
        delete_key(&static_meshes, entity)
    }
    clear(&static_meshes)
}


add :: proc(entity : d.Entity, mesh_id : d.MeshId, mat : ^ge.Material) {
    stat_mesh := new(StaticMesh)
    stat_mesh.material = mat
    stat_mesh.render_object_id =ge.render_mesh(mesh_id, transform.getPosition(entity), mat)

    static_meshes[entity] = stat_mesh

}