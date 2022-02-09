public struct RoutingQueueTaskIdentifier:
    RawRepresentable,
    ExpressibleByStringInterpolation,
    Hashable
{
    // MARK: - RawRepresentable

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }

    public var rawValue: String

    // MARK: - ExpressibleByStringInterpolation

    public init(stringInterpolation: String) {
        self.rawValue = stringInterpolation
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}
