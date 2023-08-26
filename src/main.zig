const std = @import("std");
const c = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});

const ceil = std.math.ceil;

const width = 800;
const height = 600;

pub fn main() !void {
    c.InitWindow(width, height, "ZigBreaker");
    c.SetTargetFPS(60);

    defer c.CloseWindow();

    const radius = 10;
    const gap: u32 = 20;
    const gridWidth: u32 = 5;
    const gridHeight: u32 = 5;
    const brickWidth: u32 = 100;
    const brickHeight: u32 = 30;

    var destroyedMap: [gridWidth * gridHeight]bool = undefined;
    @memset(&destroyedMap, false);

    var fpsText: [20]u8 = undefined;

    var paddle = c.Rectangle{
        .x = width / 2 - 100,
        .y = height - 70,
        .width = 200,
        .height = 20,
    };

    var pos = c.Vector2{
        .x = width / 2 - 25,
        .y = 0,
    };
    var speed = c.Vector2{
        .x = 200.0,
        .y = 200.0,
    };

    var offsetX: u32 = 100;
    var offsetY: u32 = 100;

    while (!c.WindowShouldClose()) {
        c.BeginDrawing();
        {
            const dt = c.GetFrameTime();
            c.ClearBackground(c.BLACK);

            // Update
            {
                paddle.x = @floatFromInt(c.GetMouseX());
                pos.y += speed.y * dt;
                pos.x += speed.x * dt;

                // Checking collision with boundaries
                if ((pos.y <= 0 and speed.y < 0.0) or
                    (pos.y >= height - radius and speed.y > 0.0))
                {
                    speed.y *= -1.0;
                }

                if ((pos.x <= 0 and speed.x < 0.0) or
                    (pos.x >= width - radius and speed.x > 0.0))
                {
                    speed.x *= -1.0;
                }

                if (c.CheckCollisionCircleRec(pos, radius, paddle)) {
                    speed = c.Vector2Scale(speed, -1.0);
                }

                for (range(gridWidth), 0..) |_, x| {
                    for (range(gridHeight), 0..) |_, y| {
                        const k = y * gridWidth + x;
                        const rec = c.Rectangle{
                            .x = @floatFromInt(x * (brickWidth + gap) + offsetX),
                            .y = @floatFromInt(y * (brickHeight + gap) + offsetY),
                            .width = brickWidth,
                            .height = brickHeight,
                        };

                        if (!destroyedMap[k] and c.CheckCollisionCircleRec(pos, radius, rec)) {
                            destroyedMap[k] = true;
                            speed = c.Vector2Scale(speed, -1.0);
                        }
                    }
                }

                @memset(&fpsText, 0);
                _ = try std.fmt.bufPrint(&fpsText, "FPS: {}", .{c.GetFPS()});
            }

            // Render
            {
                for (range(gridWidth), 0..) |_, x| {
                    for (range(gridHeight), 0..) |_, y| {
                        const k = y * gridWidth + x;
                        if (!destroyedMap[k]) {
                            const X: c_int = @intCast(x * (brickWidth + gap) + offsetX);
                            const Y: c_int = @intCast(y * (brickHeight + gap) + offsetY);
                            c.DrawRectangle(X, Y, brickWidth, brickHeight, c.YELLOW);
                        }
                    }
                }

                const X: c_int = @intFromFloat(pos.x);
                const Y: c_int = @intFromFloat(pos.y);
                c.DrawCircle(X, Y, radius, c.GREEN);
                c.DrawRectangleRec(paddle, c.RED);
                c.DrawText(&fpsText, 10, 10, 20, c.LIGHTGRAY);
            }
        }
        c.EndDrawing();
    }
}

pub fn range(len: usize) []const void {
    return @as([*]void, undefined)[0..len];
}
