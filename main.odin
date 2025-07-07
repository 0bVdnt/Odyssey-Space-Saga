package main

import "core:math" // Import the math library of odin
import "core:math/rand" // Import rand to generate sudo-random star positions
import rl "vendor:raylib" // Import raylib with an alias 'rl'

// --- Data Structures ---
Player :: struct {
    pos:      rl.Vector2,
    vel:      rl.Vector2,
    size:     f32,
    rotation: f32,
}

// --- Main Program ---
main :: proc() {
    // Constants
    screen_W  :: 800
    screen_H :: 600

    rl.InitWindow(screen_W, screen_H, "Odyssey")
    defer rl.CloseWindow() // `defer` schedules a call to rl.CloseWindow() to execute automatically right before main procedure finishes. This ensures proper closing of window.
    rl.SetTargetFPS(60)

    // Create player instance
    player := Player {
        pos      = { f32(screen_W) / 2, f32(screen_H) / 2}, // Place in the center of the screen initially
        vel      = {0, 0}, // Start with zero velocity
        size     = 20, // In Pixels
        rotation = 0,
    }

    STAR_COUNT :: 400 // Number of stars
    stars: [STAR_COUNT]rl.Vector2

    // Create a random number generator, here it is seeded with `69420` which makes the random occurance of star pattern the same every render
    r := rand.create(69420) 
    // rand.float32(&r) gives a number between 0.0 and 1.0.
    // Multiply it by the screen dimension to get a random coordinate.
    for i in 0..<STAR_COUNT {
        stars[i] = {
            rand.float32() * f32(screen_W),  // Random x
            rand.float32() * f32(screen_H),  // Random y
        }
    }

    // --- Main Game Loop ---
    for !rl.WindowShouldClose() {
        // --- Update ---
        // Get the time elapsed since the last frame.
        dt := rl.GetFrameTime() // delta time

        // Handle rotation
        rotation_velo :: 200.0 // degrees per second
        if rl.IsKeyDown(.A) {
            player.rotation -= rotation_velo * dt
        }
        if rl.IsKeyDown(.D) {
            player.rotation += rotation_velo * dt
        }

        // Handle thrust
        thrust :: 250.0
        if rl.IsKeyDown(.W) {
            // Calculate the forward direction vector based on the ship's rotation
            fwd_dir := rl.Vector2{ math.sin(player.rotation * rl.DEG2RAD), -math.cos(player.rotation * rl.DEG2RAD) } // Negative because here by convention `+y` is down 
            // Add thrust to the velocity (scaled by delta time)
            player.vel += fwd_dir * thrust * dt
        }
        
        // Update player position based on velocity
        player.pos += player.vel * dt
       
        // Add/Subtract player.size to make the ship fully disappear before it wraps.
        if player.pos.x > f32(screen_W) + player.size
            { player.pos.x = -player.size }

        if player.pos.x < -player.size                    
            { player.pos.x = f32(screen_W) + player.size }

        if player.pos.y > f32(screen_H) + player.size 
            { player.pos.y = -player.size }

        if player.pos.y < -player.size
            { player.pos.y = f32(screen_H) + player.size }

        // --- Drawing ---
        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.ClearBackground(rl.BLACK)

        // --- Draw the stars ---
        for star_pos in stars {
            rl.DrawPixelV(star_pos, rl.WHITE)
        }

        // Calculate triangle points using the new '+' operator syntax
        v1 := player.pos + rl.Vector2{ math.sin(player.rotation * rl.DEG2RAD) * player.size, -math.cos(player.rotation * rl.DEG2RAD) * player.size }
        v2 := player.pos + rl.Vector2{ math.sin((player.rotation-150) * rl.DEG2RAD) * player.size, -math.cos((player.rotation-150) * rl.DEG2RAD) * player.size }
        v3 := player.pos + rl.Vector2{ math.sin((player.rotation+150) * rl.DEG2RAD) * player.size, -math.cos((player.rotation+150) * rl.DEG2RAD) * player.size }

        rl.DrawTriangleLines(v1, v2, v3, rl.WHITE)
    }
}
