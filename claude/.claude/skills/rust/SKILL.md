---
name: rust
description: Rust conventions, patterns, and tooling. Loaded automatically when working with Rust projects.
user-invocable: false
---

# Rust Conventions

## Documentation

Module-level docs with `//!`:
```rust
//! This module provides utilities for...
```

Item docs with `///`:
```rust
/// Adds two numbers together.
///
/// # Examples
///
/// ```
/// let result = add(1, 2);
/// assert_eq!(result, 3);
/// ```
///
/// # Errors
///
/// Returns an error if overflow occurs.
fn add(a: i32, b: i32) -> Result<i32, Error> {
```

## Testing

Unit tests in same file:
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add_positive() {
        assert_eq!(add(1, 2), 3);
    }

    #[test]
    #[should_panic(expected = "overflow")]
    fn test_add_overflow() {
        add(i32::MAX, 1);
    }
}
```

Integration tests in `tests/` directory.

## Commands

- Build: `cargo build`
- Test: `cargo test`
- Lint: `cargo clippy`
- Format: `cargo fmt`
- Check: `cargo check` (faster than build)
- Doc: `cargo doc --open`
- Run: `cargo run`

## Error Handling

- Use `Result<T, E>` for recoverable errors
- Use `?` operator for propagation
- Prefer `thiserror` for library errors, `anyhow` for applications
- Avoid `.unwrap()` in library code; use `.expect("reason")` when panic is intentional

## Patterns

- Prefer `&str` over `String` in function parameters
- Use `impl Trait` for return types when concrete type is complex
- Derive common traits: `Debug`, `Clone`, `PartialEq`
- Use `#[must_use]` for functions whose return value shouldn't be ignored
- Prefer iterators over manual loops
- Use `Default` trait for structs with sensible defaults

## Lifetimes

Elision rules handle most cases. Annotate explicitly when:
```rust
// Returning a reference requires lifetime annotation
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}

// Struct holding references needs lifetime
struct Parser<'a> {
    input: &'a str,
}

// Multiple lifetimes when references have different scopes
fn process<'a, 'b>(data: &'a str, config: &'b Config) -> &'a str {
```

Guidelines:
- Let the compiler guide you; add lifetimes when it complains
- Prefer owned data (`String`, `Vec<T>`) over references in structs when lifetime complexity grows
- Use `'static` only for compile-time constants or intentionally leaked data
- Consider `Cow<'a, str>` when you might need to own or borrow

## Async Patterns

Use `tokio` runtime (or `async-std`):
```rust
#[tokio::main]
async fn main() {
    let result = fetch_data().await;
}

async fn fetch_data() -> Result<Data, Error> {
    let response = client.get(url).send().await?;
    response.json().await
}
```

Concurrency:
```rust
// Run futures concurrently
let (a, b) = tokio::join!(fetch_a(), fetch_b());

// Race futures, return first to complete
let result = tokio::select! {
    val = fetch_a() => val,
    val = fetch_b() => val,
};

// Spawn independent tasks
let handle = tokio::spawn(async move {
    expensive_work().await
});
```

Guidelines:
- Use `async fn` over `-> impl Future` for readability
- Avoid `block_on` inside async context; propagate async up
- Use `tokio::sync::Mutex` (not `std::sync::Mutex`) when holding across `.await`
- Prefer channels (`mpsc`, `oneshot`) for task communication
- Add timeouts with `tokio::time::timeout` for network operations
- Use `Send + Sync` bounds when spawning tasks that share data
