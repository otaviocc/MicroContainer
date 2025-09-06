import Foundation

/// A tiny, thread-safe dependency injection container.
///
/// - Supports singleton (static) and factory (dynamic) lifetimes.
/// - Optional qualifiers for multiple registrations of the same type.
/// - Thread-safe registration and resolution.
/// - Factories receive the container, enabling nested resolutions.
public final class DependencyContainer {

    // MARK: - Properties

    private let lock = NSRecursiveLock()
    private var dependencies: [DependencyName: Any] = [:]
    private var staticDependencies: [DependencyName: Any] = [:]
    private let resolutionStackKey = "MicroContainer.ResolutionStack"

    // MARK: - Life cycle

    /// Creates an empty container.
    public init() {}

    // MARK: - Public

    /// Errors that may occur during dependency resolution.
    public enum ResolutionError: Error {

        /// No registration exists for the requested type.
        case notRegistered(type: Any.Type)
        /// A circular dependency was detected while resolving.
        ///
        /// The payload contains the human-readable chain of types involved
        /// in the cycle, in the order they were attempted.
        case circularChain(chain: [String])
    }

    /// Registers a dependency.
    ///
    /// - Parameters:
    ///   - type: The type to register under (usually a protocol or concrete type).
    ///   - allocation: The lifetime of the dependency (singleton or factory).
    ///   - qualifier: Optional name to distinguish multiple registrations for the same `type`.
    ///   - factory: A factory closure that creates the instance; receives the container for nested resolution.
    /// - Note: Thread-safe.
    public func register<T>(
        type: T.Type,
        allocation: DependencyAllocation,
        qualifier: String? = nil,
        factory: @escaping (DependencyContainer) -> T
    ) {
        lock.lock()
        defer { lock.unlock() }
        let dependencyKey = DependencyName(type: T.self, qualifier: qualifier)

        let dependency = Dependency(
            type: dependencyKey,
            allocation: allocation,
            factory: factory
        )

        dependencies[dependency.type] = dependency
    }

    /// Registers a dependency with singleton (static) lifetime.
    ///
    /// - Parameters:
    ///   - type: The type to register under.
    ///   - qualifier: Optional name to distinguish multiple registrations for the same `type`.
    ///   - factory: A factory closure that creates the instance on first resolve.
    public func registerSingleton<T>(
        _ type: T.Type,
        qualifier: String? = nil,
        factory: @escaping (DependencyContainer) -> T
    ) {
        register(type: type, allocation: .static, qualifier: qualifier, factory: factory)
    }

    /// Registers a dependency with factory (dynamic) lifetime.
    ///
    /// - Parameters:
    ///   - type: The type to register under.
    ///   - qualifier: Optional name to distinguish multiple registrations for the same `type`.
    ///   - factory: A factory closure invoked on every resolve.
    public func registerFactory<T>(
        _ type: T.Type,
        qualifier: String? = nil,
        factory: @escaping (DependencyContainer) -> T
    ) {
        register(type: type, allocation: .dynamic, qualifier: qualifier, factory: factory)
    }

    /// Resolves a dependency or crashes if not registered.
    ///
    /// - Returns: The resolved instance.
    /// - Parameters:
    ///   - qualifier: Optional name to distinguish which registration to resolve.
    /// - Warning: Triggers a runtime crash if the type is not registered. Prefer `resolveOptional()`
    ///            or `resolveOrThrow()` for safer behavior.
    /// - Note: Thread-safe.
    public func resolve<T>(qualifier: String? = nil) -> T {
        let dependencyKey = DependencyName(type: T.self, qualifier: qualifier)

        lock.lock()
        guard let dependency = dependencies[dependencyKey] as? Dependency<T> else {
            lock.unlock()
            fatalError("Type not registered: \(T.self)")
        }

        if let cycle = beginResolution(for: dependencyKey) {
            lock.unlock()
            fatalError("Circular dependency detected: \(cycle.joined(separator: " -> "))")
        }

        switch dependency.allocation {
        case .dynamic:
            let factory = dependency.factory
            lock.unlock()
            let value: T = factory(self)
            endResolution(for: dependencyKey)
            return value
        case .static:
            if let resolvedDependency = staticDependencies[dependencyKey] as? T {
                lock.unlock()
                endResolution(for: dependencyKey)
                return resolvedDependency
            } else {
                let resolvedDependency = dependency.factory(self)
                staticDependencies[dependencyKey] = resolvedDependency
                lock.unlock()
                endResolution(for: dependencyKey)
                return resolvedDependency
            }
        }
    }

    /// Resolves a dependency if registered.
    ///
    /// - Returns: The resolved instance or `nil` if not registered.
    /// - Parameters:
    ///   - qualifier: Optional name to distinguish which registration to resolve.
    /// - Note: Thread-safe.
    public func resolveOptional<T>(qualifier: String? = nil) -> T? {
        let dependencyKey = DependencyName(type: T.self, qualifier: qualifier)

        lock.lock()
        guard let dependency = dependencies[dependencyKey] as? Dependency<T> else {
            lock.unlock()
            return nil
        }

        if beginResolution(for: dependencyKey) != nil {
            lock.unlock()
            return nil
        }

        switch dependency.allocation {
        case .dynamic:
            let factory = dependency.factory
            lock.unlock()
            let value: T = factory(self)
            endResolution(for: dependencyKey)
            return value
        case .static:
            if let resolvedDependency = staticDependencies[dependencyKey] as? T {
                lock.unlock()
                endResolution(for: dependencyKey)
                return resolvedDependency
            } else {
                let resolvedDependency = dependency.factory(self)
                staticDependencies[dependencyKey] = resolvedDependency
                lock.unlock()
                endResolution(for: dependencyKey)
                return resolvedDependency
            }
        }
    }

    /// Resolves a dependency or throws if not registered.
    ///
    /// - Returns: The resolved instance.
    /// - Throws: ``ResolutionError/notRegistered(type:)`` when no registration exists.
    /// - Parameters:
    ///   - qualifier: Optional name to distinguish which registration to resolve.
    /// - Note: Thread-safe.
    public func resolveOrThrow<T>(qualifier: String? = nil) throws -> T {
        let dependencyKey = DependencyName(type: T.self, qualifier: qualifier)

        lock.lock()
        guard let dependency = dependencies[dependencyKey] as? Dependency<T> else {
            lock.unlock()
            throw ResolutionError.notRegistered(type: T.self)
        }

        if let cycle = beginResolution(for: dependencyKey) {
            lock.unlock()
            throw ResolutionError.circularChain(chain: cycle)
        }

        switch dependency.allocation {
        case .dynamic:
            let factory = dependency.factory
            lock.unlock()
            let value: T = factory(self)
            endResolution(for: dependencyKey)
            return value
        case .static:
            if let resolvedDependency = staticDependencies[dependencyKey] as? T {
                lock.unlock()
                endResolution(for: dependencyKey)
                return resolvedDependency
            } else {
                let resolvedDependency = dependency.factory(self)
                staticDependencies[dependencyKey] = resolvedDependency
                lock.unlock()
                endResolution(for: dependencyKey)
                return resolvedDependency
            }
        }
    }

    /// Indicates whether a registration exists for a type.
    ///
    /// - Parameters:
    ///   - type: The type to check.
    ///   - qualifier: Optional name to check for a specific registration.
    /// - Returns: `true` if registered; otherwise `false`.
    public func contains<T>(
        _ type: T.Type,
        qualifier: String? = nil
    ) -> Bool {
        let dependencyKey = DependencyName(type: T.self, qualifier: qualifier)
        lock.lock()
        defer { lock.unlock() }
        return dependencies[dependencyKey] != nil
    }

    /// Removes an existing registration (and any cached singleton instance).
    ///
    /// - Parameters:
    ///   - type: The type whose registration should be removed.
    ///   - qualifier: Optional name to remove a specific registration.
    public func unregister<T>(
        _ type: T.Type,
        qualifier: String? = nil
    ) {
        let dependencyKey = DependencyName(type: T.self, qualifier: qualifier)
        lock.lock()
        dependencies.removeValue(forKey: dependencyKey)
        staticDependencies.removeValue(forKey: dependencyKey)
        lock.unlock()
    }

    /// Clears all registrations and cached singleton instances.
    public func reset() {
        lock.lock()
        dependencies.removeAll(keepingCapacity: false)
        staticDependencies.removeAll(keepingCapacity: false)
        lock.unlock()
    }

    /// Instantiates and caches all singleton (static) registrations.
    ///
    /// Useful for pre-warming singletons at startup to surface failures early and reduce first-use latency.
    public func warmSingletons() {
        lock.lock()
        let entries = dependencies
        lock.unlock()

        for (key, anyDependency) in entries {
            guard let dep = anyDependency as? AnyDependencyFactoryInvocable, dep.allocation == .static else { continue }

            lock.lock()
            if staticDependencies[key] == nil {
                let instance = dep.invokeFactory(with: self)
                staticDependencies[key] = instance
            }
            lock.unlock()
        }
    }
}

// MARK: - Circular dependency tracking

private extension DependencyContainer {

    func beginResolution(for key: DependencyName) -> [String]? {
        let name = String(describing: key)
        var stack = Thread.current.threadDictionary[resolutionStackKey] as? [String] ?? []
        if stack.contains(name) {
            return stack + [name]
        }
        stack.append(name)
        Thread.current.threadDictionary[resolutionStackKey] = stack
        return nil
    }

    func endResolution(for key: DependencyName) {
        let name = String(describing: key)
        var stack = Thread.current.threadDictionary[resolutionStackKey] as? [String] ?? []
        if stack.last == name {
            stack.removeLast()
        } else {
            stack.removeAll()
        }
        Thread.current.threadDictionary[resolutionStackKey] = stack
    }
}
