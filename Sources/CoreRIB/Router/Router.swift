import Combine
import Core
import RouterIdentifier
import os

private let logger = Logger("routing")

open class Router: Routable {
    public init(id: RouterIdentifier) {
        self.id = id
    }

    internal let stateValueSubject = CurrentValueSubject<RouterState, Never>(.detached)
    private let eventPassthroughSubject = PassthroughSubject<RouterEvent, Never>()

    internal var name: String {
        "\(Self.self)"
            .replacingOccurrences(of: "Router", with: "")
            .replacingOccurrences(of: "Impl", with: "")
    }

    private func child(for id: RouterIdentifier) -> Routable? {
        children.first { $0.id == id }
    }

    private func removeChildren(with id: RouterIdentifier) {
        children.removeAll { $0.id == id }
    }

    // MARK: - Overridable methods

    @MainActor
    open func didRequestAttaching() async { }

    @MainActor
    open func didRequestDetaching() async { }

    // MARK: - Routable

    public let id: RouterIdentifier

    public var children = [Routable]()

    public var state: RouterState {
        stateValueSubject.value
    }

    public var statePublisher: ValuePublisher<RouterState> {
        stateValueSubject.eraseToAnyPublisher()
    }

    public var eventPublisher: ValuePublisher<RouterEvent> {
        eventPassthroughSubject.eraseToAnyPublisher()
    }

    public func attach(_ child: Routable) async {
        guard self !== child else {
            logger.error("Attaching self as a child is not allowed")
            appAssertionFailure()
            return
        }

        guard self.child(for: child.id).isNil else {
            logger.warning("Attemp to attach \(child.name) to \(self.name) which is already attached. Aborting...")
            return
        }

        logger.log("Attaching \(child.name) to \(self.name)")

        children.append(child)

        if let router = child as? Router {
            router.stateValueSubject.value = .attaching
            await router.didRequestAttaching()
            router.stateValueSubject.value = .attached
        }

        eventPassthroughSubject.send(.didAttachChild(child.id))
    }

    public func detach(_ identifier: RouterIdentifier) async {
        guard let child = child(for: identifier) else {
            logger.warning("Failed to find child in \(self.name)'s children with \(identifier) id. Trying to find it deeper...")

            for child in children.compactMap({ $0 as? Router }) {
                if child.child(for: identifier).isNotNil {
                    await child.detach(identifier)
                    return
                }
            }

            logger.error("Failed to find child in \(self.name)'s children with \(identifier) id")
            appAssertionFailure()
            return
        }

        logger.log("Detaching \(child.name) from \(self.name)")

        if let router = child as? Router {
            router.stateValueSubject.value = .detaching
            await router.didRequestDetaching()
            router.stateValueSubject.value = .detached
        }

        removeChildren(with: identifier)
        eventPassthroughSubject.send(.didDetachChild(identifier))
    }
}
