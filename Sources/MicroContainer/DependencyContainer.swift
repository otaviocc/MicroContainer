import Foundation

public final class DependencyContainer {

    // MARK: - Properties

    private let lock = NSRecursiveLock()
    private var dependencies: [DependencyName: Any] = [:]
    private var staticDependencies: [DependencyName: Any] = [:]

    // MARK: - Life cycle

    public init() {}

    // MARK: - Public

    public func register<T>(
        type: T.Type,
        allocation: DependencyAllocation,
        factory: @escaping (DependencyContainer) -> T
    ){
        lock.lock()
        defer { lock.unlock() }
        let dependencyKey = DependencyName(type: T.self)

        let dependency = Dependency(
            type: dependencyKey,
            allocation: allocation,
            factory: factory
        )

        dependencies[dependency.type] = dependency
    }

    public func resolve<T>() -> T {
        let dependencyKey = DependencyName(type: T.self)

        lock.lock()
        guard let dependency = dependencies[dependencyKey] as? Dependency<T> else {
            lock.unlock()
            fatalError("\(dependencyKey) not registered")
        }

        switch dependency.allocation {
        case .dynamic:
            let factory = dependency.factory
            lock.unlock()
            return factory(self)
        case .static:
            if let resolvedDependency = staticDependencies[dependencyKey] as? T {
                lock.unlock()
                return resolvedDependency
            } else {
                let resolvedDependency = dependency.factory(self)
                staticDependencies[dependencyKey] = resolvedDependency
                lock.unlock()
                return resolvedDependency
            }
        }
    }
}
