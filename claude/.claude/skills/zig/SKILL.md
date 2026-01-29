---
name: zig
description: Zig conventions, patterns, and tooling. Loaded automatically when working with Zig projects.
user-invocable: false
---

# Zig Conventions

## Documentation

Doc comments with `///`:
```zig
/// Adds two numbers together.
/// Returns the sum.
fn add(a: i32, b: i32) i32 {
    return a + b;
}
```

## Testing

Built-in test blocks:
```zig
test "add positive numbers" {
    const result = add(1, 2);
    try std.testing.expectEqual(@as(i32, 3), result);
}
```

## Commands

- Build: `zig build`
- Test: `zig test src/main.zig`
- Run: `zig run src/main.zig`
