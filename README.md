# MicroContainer

A tiny, dependency-free Dependency Injection (DI) container for Swift.

- Minimal API surface
- Singleton (static) and factory (dynamic) lifetimes
- Factories receive the container for nested resolution
- Thread-safe registration and resolution
- Optional qualifiers (named registrations)
- Safer resolve variants and circular dependency detection

## Installation

Add MicroContainer to your Package.swift dependencies:

```swift
.package(url: "https://github.com/your/repo.git", from: "1.0.0")
```

## Quick Start

```swift
let container = DependencyContainer()

// Register a singleton (cached on first resolve)
container.registerSingleton(ServiceProtocol.self) { _ in
    Service()
}

// Register a factory (new instance each time)
container.registerFactory(Repository.self) { _ in
    Repository()
}

// Resolve
let service: ServiceProtocol = container.resolve()
let repo: Repository = container.resolve()
```

## Qualifiers (named registrations)

Register multiple implementations under the same type by using `qualifier`:

```swift
container.registerSingleton(Client.self, qualifier: "primary") { _ in
    Client(baseURL: URL(string: "https://api.example.com")!)
}
container.registerSingleton(Client.self, qualifier: "staging") {
    _ in Client(baseURL: URL(string: "https://staging.example.com")!)
}

let primary: Client = container.resolve(qualifier: "primary")
let staging: Client = container.resolve(qualifier: "staging")
```

## Safer resolve variants

```swift
let maybeService: Service? = container.resolveOptional()

do {
    let service: Service = try container.resolveOrThrow()
} catch DependencyContainer.ResolutionError.notRegistered(let type) {
    print("Missing registration: \(type)")
}
```

## Utilities

```swift
// Presence
container.contains(Service.self)

// Remove
container.unregister(Service.self)

// Reset all registrations and caches
container.reset()

// Warm up all singletons (instantiate eagerly)
container.warmSingletons()
```

## Circular dependency detection

If a factory resolves a type that forms a cycle, MicroContainer detects it:

- `resolve()` fatals with a readable dependency chain
- `resolveOrThrow()` throws `ResolutionError.circularChain(chain:)`

## Thread-safety

All registration and resolution operations are thread-safe. Singleton creation is atomic.

## License

MIT. See `LICENSE`.
