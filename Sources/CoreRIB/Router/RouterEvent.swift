import RouterIdentifier

public enum RouterEvent {
    case didAttachChild(RouterIdentifier)
    case didDetachChild(RouterIdentifier)
}
