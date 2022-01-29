public protocol PopoverViewControllerCompatible {
    var canCloseAsPopover: Bool { get }
    func didAttemptToCloseAsPopover()
}

extension PopoverViewControllerCompatible {
    public var canCloseAsPopover: Bool { true }
    public func didAttemptToCloseAsPopover() { }
}
