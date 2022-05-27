final class Dependency<T>: Hashable, Equatable {

    // MARK: - Properties

    let type: DependencyName
    let allocation: DependencyAllocation
    let factory: (DependencyContainer) -> T

    // MARK: - Life cycle

    init(
        type: DependencyName,
        allocation: DependencyAllocation,
        factory: @escaping (DependencyContainer) -> T
    ){
        self.type = type
        self.allocation = allocation
        self.factory = factory
    }

    // MARK: - Public

    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(type)
        hasher.combine(allocation)
    }

    static func == (
        lhs: Dependency,
        rhs: Dependency
    ) -> Bool {
        lhs.type == rhs.type && lhs.allocation == rhs.allocation
    }
}
