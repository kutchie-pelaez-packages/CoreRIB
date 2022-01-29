import Core
import UIKit

public final class PopoverPresentationContext:
    NSObject,
    PresentationContext,
    UIAdaptivePresentationControllerDelegate
{

    public init(
        source: UIViewController,
        prefersGrabberVisible: Bool = false,
        detents: [UISheetPresentationController.Detent] = [.large()],
        selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = nil,
        largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = nil,
        prefersScrollingExpandsWhenScrolledToEdge: Bool = true,
        didDismiss: @escaping Block
    ) {
        self.source = source
        self.prefersGrabberVisible = prefersGrabberVisible
        self.detents = detents
        self.selectedDetentIdentifier = selectedDetentIdentifier
        self.largestUndimmedDetentIdentifier = largestUndimmedDetentIdentifier
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        self.didDismiss = didDismiss
        super.init()
    }

    private let source: UIViewController
    private var prefersGrabberVisible: Bool
    private let detents: [UISheetPresentationController.Detent]
    private var selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier?
    private var largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?
    private var prefersScrollingExpandsWhenScrolledToEdge: Bool
    private var didDismiss: Block

    // MARK: - PresentationContext

    public func present(_ viewController: UIViewController) async {
        guard source.presentedViewController.isNil else { return }

        viewController.presentationController?.delegate = self
        viewController.sheetPresentationController?.prefersGrabberVisible = prefersGrabberVisible
        viewController.sheetPresentationController?.detents = detents
        viewController.sheetPresentationController?.selectedDetentIdentifier = selectedDetentIdentifier
        viewController.sheetPresentationController?.largestUndimmedDetentIdentifier = largestUndimmedDetentIdentifier
        viewController.sheetPresentationController?.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge

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
        await withCheckedContinuation { continuation in
            viewController.dismiss(
                animated: true,
                completion: {
                    continuation.resume()
                }
            )
        }
    }

    // MARK: - UIAdaptivePresentationControllerDelegate

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        didDismiss()
    }

    public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        if let controller = presentationController.presentedViewController as? PopoverViewControllerCompatible {
            return controller.canCloseAsPopover
        } else {
            return true
        }
    }

    public func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        if let controller = presentationController.presentedViewController as? PopoverViewControllerCompatible {
            controller.didAttemptToCloseAsPopover()
        } else if let navigationController = presentationController.presentedViewController.navigationController as? PopoverViewControllerCompatible {
            navigationController.didAttemptToCloseAsPopover()
        }
    }
}
