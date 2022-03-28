import Core
import Foundation
import RouterIdentifier

public enum RoutingQueueTaskCondition {
    case condition(Resolver<Bool>, VoidPublisher)
    case attachedRouterInTree(RouterIdentifier)
    case noRouterInTree(RouterIdentifier)

    public static func autoCheckingCondition(
        resolver: @escaping Resolver<Bool>,
        tick interval: TimeInterval
    ) -> RoutingQueueTaskCondition {
        let timerPublisher = Timer.TimerPublisher(
            interval: interval,
            runLoop: .main,
            mode: .default
        )

        return .condition(
            resolver,
            timerPublisher
                .autoconnect()
                .voided()
        )
    }
}
