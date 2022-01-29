public struct ScopedRouterFactory<Args>: RouterFactory {
    public let factory: (Args) -> Routable

    public func produce(dependencies: Args) -> Routable {
        factory(dependencies)
    }
}
