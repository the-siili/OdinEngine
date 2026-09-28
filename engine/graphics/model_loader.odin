// An elementary program in Odin which creates a colored cube
// which rotates over time.
//
// Created by Benjamin Thompson. Available at:
// https://github.com/bg-thompson/OpenGL-Tutorials-In-Odin
// Last updated: 2024.09.15
//
// To compile and run the program with optimizations, use the command
//
//     odin run Rotating-Cube -o:speed
//
// Created for educational purposes. Used verbatim, it is probably
// unsuitable for production code.

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



load_obj ::proc(obj_string: string) -> (vertices:[]f32, indices : []u32){
    vertice_array : [dynamic][3]f32 = {}
    normal_array : [dynamic][3]f32 = {}
    uv_array : [dynamic][2]f32 = {}
    index_array : [dynamic][3]u32 = {}
    defer delete_dynamic_array(vertice_array)
    defer delete_dynamic_array(normal_array)
    defer delete_dynamic_array(uv_array)
    defer delete_dynamic_array(index_array)
    lines := strings.split_lines(obj_string)
    defer delete_slice(lines)
    for line in lines{
        items := strings.split(line, " ")
        defer delete_slice(items)
        if items[0] == "v"{
            x, _ := strconv.parse_f32(items[1])
            y, _ := strconv.parse_f32(items[2])
            z, _ := strconv.parse_f32(items[3])

            append(&vertice_array, [3]f32{x, y, z})
        }
        else if items[0] == "vn"{
            x, _ := strconv.parse_f32(items[1])
            y, _ := strconv.parse_f32(items[2])
            z, _ := strconv.parse_f32(items[3])

            append(&normal_array, [3]f32{x, y, z})
        }
        else if items[0] == "vt"{
            x, _ := strconv.parse_f32(items[1])
            y, _ := strconv.parse_f32(items[2])

            append(&uv_array, [2]f32{x, y})
        }
        else if items[0] == "f"{
            for item in items[1:]{
                inds := strings.split(item, "/")
                defer delete_slice(inds)
                vert_index, _ := strconv.parse_int(inds[0])
                uv_index, _ := strconv.parse_int(inds[1])
                normal_index, _ := strconv.parse_int(inds[2])

                append(&index_array, [3]u32{u32(vert_index-1), u32(uv_index-1), u32(normal_index-1)})
            }
        }
    }

    final_v : [dynamic][8]f32 ={}
    defer delete_dynamic_array(final_v)
    for row in vertice_array{
        append(&final_v, [8]f32{row.x, row.y, row.z, 0, 0, 0, 0, 0})
    }

    final_ia :[dynamic]u32={}
    for row in index_array{
        append(&final_ia, row.x)

        final_v[row.x][3] = uv_array[row.y].x
        final_v[row.x][4] = uv_array[row.y].y
        final_v[row.x][5] = normal_array[row.z].x
        final_v[row.x][6] = normal_array[row.z].y
        final_v[row.x][7] = normal_array[row.z].z

    }
    return_v : [dynamic]f32 = {}
    return_ia :[]u32 = final_ia[:]
    for row in final_v{
        for item in row{
            append(&return_v, item)
        }
    }
    final_return_v := return_v[:]
    return return_v[:], return_ia
}