import CardTransition
import UIKit

public final class CardPresentationContext: NSObject, PresentationContext, UIViewControllerTransitioningDelegate {
    public init(source: UIViewController) {
        self.source = source
        super.init()
    }

    private let source: UIViewController

    private let transitioningDelegate = CardTransitioningDelegate()

    // MARK: - PresentationContext

    public func present(_ viewController: UIViewController) async {
        guard source.presentedViewController.isNil else { return }

        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = transitioningDelegate

        await withCheckedContinuation { continuation in
            source.present(
                viewController,
                animated: true,
                completion: {
                    continuation.resume()
                }
            )
        }
    }

    public func dismiss(_ viewController: UIViewController) async {
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self

        await withCheckedContinuation { continuation in
            viewController.dismiss(
                animated: true,
                completion: {
                    continuation.resume()
                }
            )
        }
    }
}
