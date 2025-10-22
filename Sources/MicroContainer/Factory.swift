/// A factory (dynamic lifetime) dependency registration.
///
/// Use in result builder syntax:
///
/// ```swift
/// let container = DependencyContainer {
///     Factory(ViewModel.self) { container in
///         ViewModel(service: container.resolve())
///     }
/// }
/// ```
public struct Factory<T>: Registration {

    // MARK: - Properties

    private let type: T.Type
    private let qualifier: String?
    private let factory: (DependencyContainer) -> T

    // MARK: - Life cycle

    /// Creates a factory registration.
    ///
    /// - Parameters:
    ///   - type: The type to register.
    ///   - qualifier: Optional qualifier for multiple registrations of the same type.
    ///   - factory: Factory closure invoked on every resolution.
    public init(
        _ type: T.Type,
        qualifier: String? = nil,
        factory: @escaping (DependencyContainer) -> T
    ) {
        self.type = type
        self.qualifier = qualifier
        self.factory = factory
    }

    // MARK: - Public

    public func apply(
        to container: DependencyContainer
    ) {
        container.registerFactory(
            type,
            qualifier: qualifier,
            factory: factory
        )
    }
}
