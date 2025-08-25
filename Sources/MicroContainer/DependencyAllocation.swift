/// Represents the lifetime of a registered dependency.
public enum DependencyAllocation {
    /// A singleton lifetime: instance is created once and reused.
    case `static`
    /// A factory lifetime: a new instance is created for every resolution.
    case `dynamic`
}
