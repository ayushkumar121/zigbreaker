const std = @import("std");
const c = @cImport(
    @cInclude("raylib.h"),
);

const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();

pub fn main() !void {
    c.InitWindow(800, 600, "Hello World");
    defer c.CloseWindow();

    c.SetTargetFPS(60);
    while (!c.WindowShouldClose()) {
        c.BeginDrawing();
        c.ClearBackground(c.RAYWHITE);
        c.DrawText("Hello World", 190, 200, 20, c.LIGHTGRAY);
        c.EndDrawing();
    }
}
