import CoreUI
import UIKit

public struct ChildPresentationContext: PresentationContext {
    public init(source: UIViewController) {
        self.source = source
    }

    private let source: UIViewController

    // MARK: - PresentationContext

    public func present(_ viewController: UIViewController) async {
        source.addChildViewController(viewController)
    }

    public func dismiss(_ viewController: UIViewController) async {
        viewController.removeFromParentViewController()
    }
}
