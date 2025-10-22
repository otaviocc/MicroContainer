/// A result builder for declarative dependency container configuration.
///
/// Enables SwiftUI-like syntax for registering dependencies:
///
/// ```swift
/// let container = DependencyContainer {
///     Singleton(Logger.self) { _ in Logger() }
///     Singleton(HTTPClient.self) { _ in HTTPClient() }
///     Factory(ViewModel.self) { container in
///         ViewModel(service: container.resolve())
///     }
/// }
/// ```
@resultBuilder
public enum DependencyBuilder {

    /// Builds an empty block.
    ///
    /// Required for empty container initialization: `DependencyContainer {}`
    public static func buildBlock() -> [Registration] {
        []
    }

    /// Converts a single registration into a partial result array.
    ///
    /// This is the entry point for building up registrations incrementally.
    public static func buildPartialBlock(
        first: Registration
    ) -> [Registration] {
        [first]
    }

    /// Accumulates registrations into the partial result array.
    ///
    /// Each subsequent registration is appended to the accumulated array.
    /// This allows unlimited registrations without overload limits.
    public static func buildPartialBlock(
        accumulated: [Registration],
        next: Registration
    ) -> [Registration] {
        accumulated + [next]
    }

    /// Builds an optional registration block.
    public static func buildOptional(
        _ component: [Registration]?
    ) -> [Registration] {
        component ?? []
    }

    /// Builds the first branch of a conditional.
    public static func buildEither(
        first component: [Registration]
    ) -> [Registration] {
        component
    }

    /// Builds the second branch of a conditional.
    public static func buildEither(
        second component: [Registration]
    ) -> [Registration] {
        component
    }

    /// Builds limited availability.
    public static func buildLimitedAvailability(
        _ component: [Registration]
    ) -> [Registration] {
        component
    }

    /// Builds an array of registrations from a loop.
    public static func buildArray(
        _ components: [Registration]
    ) -> [Registration] {
        components
    }
}
