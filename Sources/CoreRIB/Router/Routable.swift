import Core
import Foundation
import RouterIdentifier

public protocol Routable: AnyObject {
    var id: RouterIdentifier { get }
    var children: [Routable] { get }
    var stateSubject: ValueSubject<RouterState> { get }
    var eventPublisher: ValuePublisher<RouterEvent> { get }
    @MainActor
    func attach(_ child: Routable) async
    @MainActor
    func detach(_ identifier: RouterIdentifier) async
}

extension Routable {
    internal var name: String {
        id.description
    }

    public func attach(_ child: Routable) {
        Task {
            await attach(child)
        }
    }

    public func detach(_ identifier: RouterIdentifier) {
        Task {
            await detach(identifier)
        }
    }
}
