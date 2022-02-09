import Combine
import Core
import Logger
import RouterIdentifier

open class Router: Routable {
    public init(id: RouterIdentifier) {
        self.id = id
    }

    internal let _stateSubject = MutableValueSubject<RouterState>(.detached)
    private let eventPassthroughSubject = PassthroughSubject<RouterEvent, Never>()

    internal var name: String {
        "\(Self.self)"
            .replacingOccurrences(of: "Router", with: "")
            .replacingOccurrences(of: "Impl", with: "")
    }

    private var root: RootRouter? {
        if let self = self as? RootRouter {
            return self
        } else if let parent = parent as? Router {
            return parent.root
        } else {
            return nil
        }
    }

    private var logger: Logger? {
        root?.logger
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

    public private(set) weak var parent: Routable?

    public private(set) var children = [Routable]()

    public var stateSubject: ValueSubject<RouterState> { _stateSubject }

    public var eventPublisher: ValuePublisher<RouterEvent> {
        eventPassthroughSubject.eraseToAnyPublisher()
    }

    public func attach(_ child: Routable) async {
        guard self !== child else {
            logger?.error("Attaching self as a child is not allowed", domain: .routing)
            safeCrash()
            return
        }

        guard self.child(for: child.id).isNil else {
            logger?.warning(
                "Attemp to attach \(child.name) to \(self.name) which is already attached. Aborting...",
                domain: .routing
            )
            return
        }

        logger?.log("Attaching \(child.name) to \(self.name)", domain: .routing)

        children.append(child)

        if let router = child as? Router {
            router.parent = self
            router._stateSubject.value = .attaching
            await router.didRequestAttaching()
            router._stateSubject.value = .attached
        }

        eventPassthroughSubject.send(.didAttachChild(child.id))
    }

    public func detach(_ identifier: RouterIdentifier) async {
        guard let child = child(for: identifier) else {
            logger?.warning(
                "Failed to find child in \(self.name)'s children with \(identifier) id. Trying to find it deeper...",
                domain: .routing
            )

            for child in children.compactMap({ $0 as? Router }) {
                if child.child(for: identifier).isNotNil {
                    await child.detach(identifier)
                    return
                }
            }

            logger?.error("Failed to find child in \(self.name)'s children with \(identifier) id", domain: .routing)
            safeCrash()
            return
        }

        logger?.log("Detaching \(child.name) from \(self.name)", domain: .routing)

        if let router = child as? Router {
            router._stateSubject.value = .detaching
            await router.didRequestDetaching()
            router._stateSubject.value = .detached
        }

        removeChildren(with: identifier)
        eventPassthroughSubject.send(.didDetachChild(identifier))
    }
}

extension LogDomain {
    fileprivate static let routing: Self = "routing"
}
