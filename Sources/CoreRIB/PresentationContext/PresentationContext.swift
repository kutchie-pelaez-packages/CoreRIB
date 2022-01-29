import UIKit

public protocol PresentationContext {
    @MainActor func present(_ viewController: UIViewController) async
    @MainActor func dismiss(_ viewController: UIViewController) async
}
