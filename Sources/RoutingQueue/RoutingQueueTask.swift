import Core
import Foundation

public struct RoutingQueueTask {
    public init(
        identifier: RoutingQueueTaskIdentifier = RoutingQueueTaskIdentifier(
            stringLiteral: UUID().uuidString
        ),
        blockable: Bool = true,
        block: @escaping @MainActor () async -> Void
    ) {
        self.identifier = identifier
        self.blockable = blockable
        self.block = block
    }

    public init(
        identifier: RoutingQueueTaskIdentifier = RoutingQueueTaskIdentifier(
            stringLiteral: UUID().uuidString
        ),
        blockable: Bool = true,
        block: @escaping Block
    ) {
        self.identifier = identifier
        self.blockable = blockable
        self.block =  {
            Task { @MainActor in
                block()
            }
        }
    }

    let identifier: RoutingQueueTaskIdentifier
    let blockable: Bool
    let block: () async -> Void
}
