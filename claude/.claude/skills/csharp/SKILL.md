---
name: csharp
description: C# conventions, patterns, and tooling. Loaded automatically when working with C# projects.
user-invocable: false
---

# C# Conventions

## Documentation Comments

Use XML doc comments:
```csharp
/// <summary>
/// Brief description.
/// </summary>
/// <param name="name">Parameter description.</param>
/// <returns>Return value description.</returns>
/// <exception cref="ArgumentException">When thrown.</exception>
```

## Testing (xUnit preferred)

```csharp
[Fact]
public void MethodName_Scenario_ExpectedResult()
{
    // Arrange
    // Act
    // Assert
}

[Theory]
[InlineData(1, 2, 3)]
public void Add_TwoNumbers_ReturnsSum(int a, int b, int expected)
```

## Commands

- Build: `dotnet build`
- Test: `dotnet test`
- Format: `dotnet format`
- Coverage: `dotnet test --collect:"XPlat Code Coverage"`

## Patterns

- Dependency injection via constructor
- `IOptions<T>` for configuration
- `ILogger<T>` for logging
- Async/await with CancellationToken
