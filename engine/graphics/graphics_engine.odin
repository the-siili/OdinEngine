
package graphics

import    "vendor:glfw"
import gl "vendor:OpenGL"
import    "core:time"
import m  "core:math"
import    "core:fmt"
import    "core:os"
import    "base:runtime"
import    "core:image"
import  png "core:image/png"
import      "core:strconv"
import      "core:strings"
import "core:mem"
import d "../definition"
import de "../debugger"




update_perspective_matrix ::proc(window : glfw.WindowHandle){
    size_x, size_y := glfw.GetWindowSize(window)
    aspect = f32(size_x)/f32(size_y)
    f := 1.0 / m.tan_f32(m.to_radians_f32(fov) / 2.0)
    perspective_mat = [16]f32 {
        f/aspect, 0, 0,  0,
        0,        f, 0,  0,
        0,        0, (far + near)/(near - far), -1,
        0,        0, (2*far*near)/(near - far), 0,
    }
}

render_screen :: proc(window : glfw.WindowHandle, time : f32) {
    de.prof_frame_part()

    view_mat := make_view_matrix(camera_location, camera_rotation)

    perspective_ptr : [^] f32 = &perspective_mat[0]
    view_ptr : [^] f32 = &view_mat[0]

    // Draw commands.
    gl.ClearColor(0.0, 0.0, 0.0, 1)
    gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
    render_background(perspective_ptr, view_ptr)
    for shader, material_list in render_object_hierarchy{
        gl.UseProgram(shaders[shader] )
        gl.UniformMatrix4fv(gl.GetUniformLocation(shaders[shader], "perspective_mat"), 1, gl.FALSE, perspective_ptr)
        gl.UniformMatrix4fv(gl.GetUniformLocation(shaders[shader], "view_mat"), 1, gl.FALSE, view_ptr)
        gl.Uniform1f(gl.GetUniformLocation(shaders[shader], "time"), time)
        for material, objects in material_list{
            bind_material_uniforms(shaders[shader], materials[material]) 
            for object_id in objects{
                de.prof_frame_part()
                object := render_objects[object_id]
                model_mat := make_model_matrix(object.location, object.scale, object.rotation)
                model_ptr : [^] f32 = &model_mat[0]
                gl.UniformMatrix4fv(gl.GetUniformLocation(shaders[shader], "model_mat"), 1, gl.FALSE, model_ptr)

                gl.BindVertexArray(meshes[object.mesh_index].vao)
                gl.DrawElements(
                    gl.TRIANGLES,
                    i32(meshes[object.mesh_index].index_count),
                    gl.UNSIGNED_INT,
                    nil,
                )
            }

        }
    }

    // for object_key in render_objects {

    //     object := render_objects[object_key]
    //     shader := shaders[materials[object.material].shader]

    //     gl.UseProgram(shader )


    //     gl.UniformMatrix4fv(gl.GetUniformLocation(shader, "perspective_mat"), 1, gl.FALSE, perspective_ptr)
    //     gl.UniformMatrix4fv(gl.GetUniformLocation(shader, "view_mat"), 1, gl.FALSE, view_ptr)
        

    //     model_mat := make_model_matrix(object.location, object.scale, object.rotation)
    //     model_ptr : [^] f32 = &model_mat[0]
    //     gl.UniformMatrix4fv(gl.GetUniformLocation(shader, "model_mat"), 1, gl.FALSE, model_ptr)
    //     bind_material_uniforms(shader, materials[object.material]) 

    //     // Set model matrix for this particular cube
    //     gl.BindVertexArray(meshes[object.mesh_index].vao)
    //     gl.DrawElements(
    //         gl.TRIANGLES,
    //         i32(meshes[object.mesh_index].index_count),
    //         gl.UNSIGNED_INT,
    //         nil,
    //     )
    // }     
    
    glfw.SwapBuffers(window)

}