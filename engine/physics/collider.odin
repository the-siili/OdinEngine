package physics
import mlin "core:math/linalg"
import "core:fmt"

Collider :: struct{
    vertecies : [8][3]f32,
    faces : [6][4]i32

}

isOverlapping :: proc(a : ^Collider, aPos : [3]f32,  b : ^Collider, bPos : [3]f32) -> (bool, [3]f32, f32){
    
    aoffset : [3]f32 = aPos-bPos
    boffset : [3]f32 = bPos-aPos
    //fmt.println(boffset)
    // fmt.println(b)
    // fmt.println(a.vertecies)
    // fmt.println(a.faces)

    penetration :f32 = 99999999
    collision_normal : [3]f32 = {0, 0, 0}
    for face in a.faces{
        
        dir : [3]f32 = mlin.cross((a.vertecies[face[1]] - a.vertecies[face[0]]), (a.vertecies[face[2]] - a.vertecies[face[0]]))
        norm : [3]f32 = dir / len(dir)

        proOffset := mlin.vector_dot(norm, aoffset)

        amin := mlin.vector_dot(norm, a.vertecies[0]);
        amax := amin;
        //fmt.println(aPos)
        //fmt.println(bPos)
        for vert in a.vertecies{
            dot := mlin.vector_dot(norm, vert);
            amin = min(amin , dot);
            amax = max(amax , dot);
        }
        bmin := mlin.vector_dot(norm, b.vertecies[0]);
        bmax := bmin;
        for vert in b.vertecies{
            dot := mlin.vector_dot(norm, vert);
            bmin = min(bmin , dot);
            bmax = max(bmax , dot);
        }
        bmin += proOffset
        bmax += proOffset
        
        if amax < bmin || bmax < amin {
            return false, {0, 0, 0}, 0
        }
        overlap := min(amax, bmax) - max(amin, bmin)

        if overlap < penetration {
            penetration = overlap
            collision_normal = norm
        }

    }

    for face in b.faces{
        
        dir : [3]f32 = mlin.cross((b.vertecies[face[1]] - b.vertecies[face[0]]),(b.vertecies[face[2]] - b.vertecies[face[0]]))
        norm : [3]f32 = dir / len(dir)

        proOffset := mlin.vector_dot(norm, boffset)

        bmin := mlin.vector_dot(norm, b.vertecies[0]);
        bmax := bmin;
        //fmt.println(aPos)
        //fmt.println(bPos)
        for vert in b.vertecies{
            dot := mlin.vector_dot(norm, vert);
            bmin = min(bmin , dot);
            bmax = max(bmax , dot);
        }
        amin := mlin.vector_dot(norm, a.vertecies[0]);
        amax := amin;
        for vert in a.vertecies{
            dot := mlin.vector_dot(norm, vert);
            amin = min(amin , dot);
            amax = max(amax , dot);
        }
        amin += proOffset
        amax += proOffset
        
        if bmax < amin || amax < bmin {
            return false, {0, 0, 0}, 0
        }

        overlap := min(bmax, amax) - max(bmin, amin)

        if overlap < penetration {
            penetration = overlap
            collision_normal = norm
        }

    }

    return true, mlin.vector_normalize(collision_normal), penetration
}