import Logger
import RouterIdentifier

public final class RootRouter: Router {
    public init(
        logger: Logger,
        id: RouterIdentifier = .root
    ) {
        self.logger = logger
        super.init(id: id)
        _stateSubject.value = .attached
    }

    let logger: Logger

    override var name: String {
        id.rawValue
    }
}

extension RouterIdentifier {
    public static var root: Self = "Root"
}
