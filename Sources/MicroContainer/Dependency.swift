struct Dependency<T> {

    // MARK: - Properties

    let type: DependencyName
    let allocation: DependencyAllocation
    let factory: (DependencyContainer) -> T

    // MARK: - Life cycle

    init(
        type: DependencyName,
        allocation: DependencyAllocation,
        factory: @escaping (DependencyContainer) -> T
    ) {
        self.type = type
        self.allocation = allocation
        self.factory = factory
    }
}

// MARK: - AnyDependencyFactoryInvocable

extension Dependency: AnyDependencyFactoryInvocable {
    func invokeFactory(
        with container: DependencyContainer
    ) -> Any {
        factory(container)
    }
}
