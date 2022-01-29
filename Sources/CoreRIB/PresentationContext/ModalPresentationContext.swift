import UIKit

public struct ModalPresentationContext: PresentationContext {
    public init(source: UIViewController) {
        self.source = source
    }

    private let source: UIViewController

    // MARK: - PresentationContext

    public func present(_ viewController: UIViewController) async {
        guard source.presentedViewController.isNil else { return }
        
        viewController.modalPresentationStyle = .fullScreen

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
}
