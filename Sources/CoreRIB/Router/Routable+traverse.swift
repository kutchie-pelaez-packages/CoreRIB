public enum RouterTraversingOrder {
    case pre
    case post
}

extension Routable {
    public func printTree() {
        var result = "\n"

        traverse(
            order: .pre,
            level: 0,
            router: self,
            using: { router, level in
                result += Array(repeating: "    ", count: level).joined()
                result += router.name
                result += "\n"
            }
        )

        print(result)
    }

    public func traverse(
        order: RouterTraversingOrder = .pre,
        using block: (Routable) -> Void
    ) {
        traverse(
            order: order,
            level: 0,
            router: self,
            using: { router, _ in
                block(router)
            }
        )
    }

    private func traverse(
        order: RouterTraversingOrder,
        level: Int,
        router: Routable,
        using block: (Routable, Int) -> Void
    ) {
        func traverseChildren() {
            router.children.forEach { child in
                traverse(
                    order: order,
                    level: level + 1,
                    router: child,
                    using: block
                )
            }
        }

        switch order {
        case .pre:
            block(router, level)
            traverseChildren()

        case .post:
            traverseChildren()
            block(router, level)
        }
    }
}
