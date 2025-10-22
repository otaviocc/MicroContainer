/// A singleton (static lifetime) dependency registration.
///
/// Use in result builder syntax:
///
/// ```swift
/// let container = DependencyContainer {
///     Singleton(Logger.self) { _ in Logger() }
/// }
/// ```
public struct Singleton<T>: Registration {

    // MARK: - Properties

    private let type: T.Type
    private let qualifier: String?
    private let factory: (DependencyContainer) -> T

    // MARK: - Life cycle

    /// Creates a singleton registration.
    ///
    /// - Parameters:
    ///   - type: The type to register.
    ///   - qualifier: Optional qualifier for multiple registrations of the same type.
    ///   - factory: Factory closure that creates the instance.
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
        container.registerSingleton(
            type,
            qualifier: qualifier,
            factory: factory
        )
    }
}
