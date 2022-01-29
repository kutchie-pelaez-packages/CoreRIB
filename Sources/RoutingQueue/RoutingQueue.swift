import Core

public protocol RoutingQueue {
    func enqueue(_ task: RoutingQueueTask, with priority: RoutingQueueTaskPriority, fulfilling conditions: [RoutingQueueTaskCondition])
    func dequeue(_ identifier: RoutingQueueTaskIdentifier)
}

extension RoutingQueue {
    public func enqueue(_ task: RoutingQueueTask, with priority: RoutingQueueTaskPriority, fulfilling conditions: RoutingQueueTaskCondition...) {
        enqueue(
            task,
            with: priority,
            fulfilling: conditions
        )
    }

    public func enqueue(_ task: RoutingQueueTask, fulfilling conditions: [RoutingQueueTaskCondition]) {
        enqueue(
            task,
            with: .default,
            fulfilling: conditions
        )
    }

    public func enqueue(_ task: RoutingQueueTask, fulfilling conditions: RoutingQueueTaskCondition...) {
        enqueue(
            task,
            fulfilling: conditions
        )
    }

    public func enqueue(_ task: RoutingQueueTask, with priority: RoutingQueueTaskPriority) {
        enqueue(
            task,
            with: priority,
            fulfilling: []
        )
    }

    public func enqueue(_ task: RoutingQueueTask) {
        enqueue(
            task,
            with: .default,
            fulfilling: []
        )
    }
}
