public final class DependencyContainer {

    // MARK: - Properties

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

        guard
            let dependency = dependencies[dependencyKey] as? Dependency<T>
        else {
            fatalError("\(dependencyKey) not registered")
        }

        switch dependency.allocation {
        case .dynamic:
            return dependency.factory(self)
        case .static:
            if let resolvedDependency = staticDependencies[dependencyKey] as? T {
                return resolvedDependency
            } else {
                let resolvedDependency = dependency.factory(self)
                staticDependencies[dependencyKey] = resolvedDependency
                return resolvedDependency
            }
        }
    }
}
