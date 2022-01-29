import CoreRIB

public struct RoutingQueueFactory {
    public init() { }

    public func produce(router: Routable) -> RoutingQueue {
        RoutingQueueImpl(router: router)
    }
}
