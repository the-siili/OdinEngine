
package graphics


import gl "vendor:OpenGL"
import "core:fmt"
import d "../definition"

@private
meshes : map[d.MeshId]Mesh
@private
next_mesh_index : d.MeshId = 0

@private
Mesh :: struct {
    vao: u32,
    vbo: u32,
    ebo: u32,
    index_count: int,
}

load_mesh :: proc(vertices : []f32, indices : []u32) -> d.MeshId{

    mesh : Mesh

    // Set up vertex array / element array / buffer objects
    gl.GenVertexArrays(1, &mesh.vao)
    gl.BindVertexArray(mesh.vao)

    gl.GenBuffers(1, &mesh.vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, mesh.vbo)

    gl.GenBuffers(1, &mesh.ebo)
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, mesh.ebo)


    // Describe GPU buffer.
    gl.BufferData(gl.ARRAY_BUFFER,     // target
                  len(vertices) * size_of(f32),   // size of the buffer object's data store
                  raw_data(vertices),           // data used for initialization
                  gl.STATIC_DRAW)      // usage

    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, 
                    len(indices)*size_of(u32), 
                    raw_data(indices), 
                    gl.STATIC_DRAW)

    // Position and color attributes. Don't forget to enable!
    //vertices coords
    gl.VertexAttribPointer(0,                   // index
                           3,                   // size
                           gl.FLOAT,            // type
                           gl.FALSE,            // normalized
                           8 * size_of(f32),    // stride
                           0)                   // offset
    //uv
    gl.VertexAttribPointer(1,                   // index
                        2,                   // size
                        gl.FLOAT,            // type
                        gl.FALSE,            // normalized
                        8 * size_of(f32),    // stride
                        3 * size_of(f32))
    //normals
    gl.VertexAttribPointer(2,                   // index
                        3,                   // size
                        gl.FLOAT,            // type
                        gl.FALSE,            // normalized
                        8 * size_of(f32),    
                        5 * size_of(f32))                     // offset
    // Enable the vertex position and color attributes defined above.
    gl.EnableVertexAttribArray(0)
    gl.EnableVertexAttribArray(1)
    gl.EnableVertexAttribArray(2)
    mesh.index_count = len(indices)

    // Optional: unbind VAO
    gl.BindVertexArray(0)
    
    meshes[next_mesh_index] = mesh
    defer next_mesh_index += 1
    return next_mesh_index
}


unload_mesh :: proc(mesh_id : d.MeshId){
    mesh := meshes[mesh_id]
    gl.DeleteBuffers(1, &mesh.vbo)
    gl.DeleteBuffers(1, &mesh.ebo)
    gl.DeleteVertexArrays(1, &mesh.vao)
    free(&mesh)

    delete_key(&meshes, mesh_id)
}