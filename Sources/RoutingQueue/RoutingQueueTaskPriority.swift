import Core

public struct RoutingQueueTaskPriority: Comparable {
    public static var low: RoutingQueueTaskPriority {
        RoutingQueueTaskPriority(importance: 250)
    }

    public static var `default`: RoutingQueueTaskPriority {
        RoutingQueueTaskPriority(importance: 500)
    }

    public static var hight: RoutingQueueTaskPriority {
        RoutingQueueTaskPriority(importance: 750)
    }

    let importance: Int

    // MARK: - Equtable

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.importance == rhs.importance
    }

    // MARK: - Comparable

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.importance < rhs.importance
    }
}
