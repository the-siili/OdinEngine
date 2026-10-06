package main

import "core:fmt"
import m "core:math"
import noise "core:math/noise"
import "core:image/netpbm"
import "core:os"

main :: proc() {
    width  := 256
    height := 256

    // Open file for writing
    handle, err := os.open("output.ppm", os.O_WRONLY | os.O_CREATE | os.O_TRUNC)
    if err != os.ERROR_NONE {
        fmt.eprintln("Could not open file")
        return
    }
    defer os.close(handle)

    // 1. Write the PPM Header (P3 means ASCII color, followed by Width, Height, Max Color Value)
    fmt.fprintf(handle, "P3\n%d %d\n255\n", width, height)


    seed: i64 = 12345
    

    // 2. Write the Image Raster (RGB triplets separated by whitespace)
    for y := 0; y < height; y += 1 {
        for x := 0; x < width; x += 1 {
            
            n := fbm(seed, [2]f64{f64(x), f64(y)}, 10, 1.0, 0.5)
            r := i32((1+m.sin_f64(f64(x) * 4.0 + n * 1)/2.0)*255)
            g := i32((1+m.sin_f64(f64(x) * 4.0 + n * 1)/2.0)*255)
            b := i32((1+m.sin_f64(f64(y) * 4.0 + n * 8)/2.0)*255)
            fmt.println((1+m.sin_f64(f64(x) * 10.0 + n * 8)/2.0)*255)
            fmt.fprintf(handle, "%d %d %d\n", r, g, b)
        }
    }
    
    fmt.println("PPM file written successfully!")
}

fbm :: proc(
    seed: i64,
    p: [2]f64,
    octaves: int,
    lacunarity: f64,
    persistence: f64,
) -> f64 {
    value: f64 = 0
    amplitude: f64 = 1
    frequency: f64 = 1
    amplitude_sum: f64 = 0

    for i := 0; i < octaves; i += 1 {
        sample := noise.noise_2d(
            seed,
            p * frequency,
        )

        value += f64(sample) * amplitude
        amplitude_sum += amplitude

        frequency *= lacunarity
        amplitude *= persistence
    }

    return value / amplitude_sum
}