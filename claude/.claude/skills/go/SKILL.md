---
name: go
description: Go conventions, patterns, and tooling. Loaded automatically when working with Go projects.
user-invocable: false
---

# Go Conventions

## Documentation

Package comment at top of file:
```go
// Package foo provides utilities for...
package foo
```

Function comments:
```go
// FunctionName does something specific.
// It returns an error if something goes wrong.
func FunctionName() error {
```

## Testing

Table-driven tests:
```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive", 1, 2, 3},
        {"negative", -1, -2, -3},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := Add(tt.a, tt.b)
            if got != tt.expected {
                t.Errorf("Add(%d, %d) = %d; want %d", tt.a, tt.b, got, tt.expected)
            }
        })
    }
}
```

## Commands

- Build: `go build`
- Test: `go test ./...`
- Coverage: `go test -cover ./...`
