package graphics

@private
mat4_mul :: proc(a, b: [16]f32) -> [16]f32 {
    result: [16]f32

    for col := 0; col < 4; col += 1 {
        for row := 0; row < 4; row += 1 {
            result[col * 4 + row] =
                a[0 * 4 + row] * b[col * 4 + 0] +
                a[1 * 4 + row] * b[col * 4 + 1] +
                a[2 * 4 + row] * b[col * 4 + 2] +
                a[3 * 4 + row] * b[col * 4 + 3]
        }
    }

    return result
}
