import Core
import UIKit

public struct WindowPresentationContext: PresentationContext {
    public init(window: UIWindow) {
        self.window = window
    }

    private let window: UIWindow

    // MARK: - PresentationContext

    public func present(_ viewController: UIViewController) async {
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }

    public func dismiss(_ viewController: UIViewController) async {
        guard window.rootViewController === viewController else {
            safeCrash()
            return
        }

        window.rootViewController = nil
    }
}
