package physics
import mlin "core:math/linalg"


Collider :: struct{
    vertecies : [][3]f32,
    faces : [][3]i32

}

isOverlapping :: proc(a : Collider, aPos : [3]f32,  b : Collider, bPos : [3]f32) -> bool{
    
    offset : [3]f32 = aPos-bPos

    for face in a.faces{
        dir : [3]f32 = (a.vertecies[face[1]] - a.vertecies[face[0]]) * (a.vertecies[face[2]] - a.vertecies[face[0]])
        norm : [3]f32 = dir / len(dir)

        proOffset := mlin.vector_dot(norm, offset)

        amin := mlin.vector_dot(norm, a.vertecies[0]);
        amax := amin;

        for vert in a.vertecies{
            dot := mlin.vector_dot(norm, vert);
            amin = min(amin , dot);
            amax = max(amax , dot);
        }
        bmin := mlin.vector_dot(norm, b.vertecies[0]);
        bmax := amin;
        for vert in b.vertecies{
            dot := mlin.vector_dot(norm, vert);
            bmin = min(bmin , dot);
            bmax = max(bmax , dot);
        }
        bmin += proOffset
        bmax += proOffset
        
        if (amin - bmax > 0) || (bmin - amax > 0){
            // there is a gap - bail
            return false;
        }

    }

    return true
}