import RouterIdentifier

public final class AnyRouter: Router {
    public override init(id: RouterIdentifier) {
        super.init(id: id)
        _stateSubject.value = .attached
    }

    override var name: String {
        id.rawValue
    }
}
