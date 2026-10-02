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


add :: proc(entity : d.Entity, w : f32, h:f32, d:f32) {
    collider := new(phy.Collider)
    collider
    phy.add_physics_body()
}

verts :[6][3]f32 = {
    {-0.5, -0.5, -0.5},
    {-0.5,-0.5,0.5},
   { -0.5,0.5,0.5},
    {0.5, -0.5, -0.5},
    {0.5, -0.5, 0.5},
    {0.5, 0.5, 0.5}
}