protocol AnyDependencyFactoryInvocable: AnyDependencyLifetimeProviding {

    func invokeFactory(with container: DependencyContainer) -> Any
}
