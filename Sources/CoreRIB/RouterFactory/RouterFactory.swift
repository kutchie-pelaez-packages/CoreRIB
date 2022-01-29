public protocol RouterFactory {
    associatedtype Dependency
    func produce(dependencies: Dependency) -> Routable
}

extension RouterFactory {
    public func scoped<T>(_ factory: @escaping (T) -> Dependency) -> ScopedRouterFactory<T> {
        ScopedRouterFactory { args in
            produce(dependencies: factory(args))
        }
    }
}
