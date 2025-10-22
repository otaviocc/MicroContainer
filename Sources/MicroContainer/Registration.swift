/// Represents a dependency registration that can be applied to a container.
public protocol Registration {

    /// Applies this registration to the given container.
    ///
    /// - Parameter container: The container to register the dependency in.
    func apply(to container: DependencyContainer)
}
