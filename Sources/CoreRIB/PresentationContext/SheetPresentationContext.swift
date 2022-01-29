import SheetTransition
import UIKit

public final class SheetPresentationContext:
    NSObject,
    PresentationContext,
    UIViewControllerTransitioningDelegate
{

    public init(source: UIViewController) {
        self.source = source
        super.init()
    }

    private let source: UIViewController

    private let presentingAnimator = SheetAnimator(direction: .presenting)
    private let dismissingAnimator = SheetAnimator(direction: .dismissing)
    private let dismissingInteractiveAnimator = SheetDismissingInteractiveAnimator()

    // MARK: - PresentationContext

    public func present(_ viewController: UIViewController) async {
        guard source.presentedViewController.isNil else { return }

        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self

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

    // MARK: - UIViewControllerTransitioningDelegate

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentingAnimator
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        dismissingAnimator
    }

    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        nil
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        dismissingInteractiveAnimator
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = SheetPresentationController(
            presentedViewController: presented,
            presenting: presenting ?? source
        )
        presentationController.link(dismissingInteractiveAnimator)

        return presentationController
    }
}
