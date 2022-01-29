import Combine
import CoreRIB
import RouterIdentifier

final class RoutingQueueImpl: RoutingQueue {
    private struct TaskInfo {
        let task: RoutingQueueTask
        let priority: RoutingQueueTaskPriority
        let conditions: [RoutingQueueTaskCondition]
        var cancellables = [AnyCancellable]()
    }

    init(router: Routable) {
        self.router = router
        subscribeToAttachedRoutersIfNeeded()
    }

    private weak var router: Routable?
    private var routerIdToEventsCancellables = [RouterIdentifier: [AnyCancellable]]()
    private var taskInfos = [TaskInfo]()

    // MARK: - Routers subscription

    private func subscribeToAttachedRoutersIfNeeded() {
        router?.traverse { [weak self] router in
            if self?.routerIdToEventsCancellables[router.id] == nil {
                self?.subscribe(to: router)
            }
        }
    }

    private func unsubscribeFromDetachedRouters() {
        var newRouterIdToEventsCancellables = [RouterIdentifier: [AnyCancellable]]()

        router?.traverse { [weak self] router in
            newRouterIdToEventsCancellables[router.id] = self?.routerIdToEventsCancellables[router.id]
        }

        self.routerIdToEventsCancellables = newRouterIdToEventsCancellables
    }

    private func subscribe(to router: Routable) {
        var cancellables = routerIdToEventsCancellables[router.id] ?? []

        router.eventPublisher
            .sink { [weak self] event in
                switch event {
                case .didAttachChild, .didDetachChild:
                    self?.subscribeToAttachedRoutersIfNeeded()
                    self?.unsubscribeFromDetachedRouters()
                    self?.executeTasksIfNeeded()
                }
            }
            .store(in: &cancellables)

        routerIdToEventsCancellables[router.id] = cancellables
    }

    // MARK: - Conditions

    private func isFulfilled(_ conditions: [RoutingQueueTaskCondition]) -> Bool {
        conditions.allSatisfy(isFulfilled)
    }

    private func isFulfilled(_ condition: RoutingQueueTaskCondition) -> Bool {
        switch condition {
        case let .condition(resolver, _):
            return resolver()

        case let .attachedRouterInTree(routerIdentifier):
            var result = false
            router?.traverse { router in
                if
                    router.id == routerIdentifier &&
                    router.stateSubject.value == .attached
                {
                    result = true
                }
            }

            return result

        case let .noRouterInTree(routerIdentifier):
            var result = true
            router?.traverse { router in
                if router.id == routerIdentifier {
                    result = false
                }
            }

            return result
        }
    }

    private func subscribeForConditions(_ conditions: [RoutingQueueTaskCondition], attachTo identifier: RoutingQueueTaskIdentifier) {
        conditions.forEach { subscribeForCondition($0, attachTo: identifier) }
    }

    private func subscribeForCondition(_ condition: RoutingQueueTaskCondition, attachTo identifier: RoutingQueueTaskIdentifier) {
        guard let taskInfoIndex = taskInfos.firstIndex(where: { $0.task.identifier == identifier }) else { return }

        switch condition {
        case let .condition(_, publisher):
            publisher
                .sink { [weak self] in
                    self?.executeTasksIfNeeded()
                }
                .store(in: &taskInfos[taskInfoIndex].cancellables)

        default:
            break
        }
    }

    // MARK: - Executing

    private func executeTasksIfNeeded() {
        Task {
            await executeFrontTasks()
            await executeNotBlockedTasks()
        }
    }

    private func executeFrontTasks() async {
        while
            let frontTaskInfo = taskInfos.first,
            isFulfilled(frontTaskInfo.conditions)
        {
            await execute(frontTaskInfo.task)
        }
    }

    private func executeNotBlockedTasks() async {
        for taskInfo in taskInfos {
            guard
                !taskInfo.task.blockable &&
                isFulfilled(taskInfo.conditions)
            else {
                return
            }

            await execute(taskInfo.task)
        }
    }

    private func execute(_ task: RoutingQueueTask) async {
        await task.block()
        dequeue(task.identifier)
    }

    // MARK: - RoutingQueue

    func enqueue(_ task: RoutingQueueTask, with priority: RoutingQueueTaskPriority, fulfilling conditions: [RoutingQueueTaskCondition]) {
        dequeue(task.identifier)

        let taskInfo = TaskInfo(
            task: task,
            priority: priority,
            conditions: conditions
        )
        taskInfos.append(taskInfo)
        taskInfos.sort { $0.priority > $1.priority }

        subscribeForConditions(
            conditions,
            attachTo: task.identifier
        )

        executeTasksIfNeeded()
    }

    func dequeue(_ identifier: RoutingQueueTaskIdentifier) {
        taskInfos.removeAll(where: { $0.task.identifier == identifier })
    }
}
