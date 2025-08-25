struct DependencyName: Equatable, Hashable, CustomStringConvertible {

    // MARK: - Properties

    private let typeId: ObjectIdentifier
    private let debugName: String
    private let qualifier: String?

    // MARK: - Life cycle

    init(type: Any.Type) {
        self.typeId = ObjectIdentifier(type)
        self.debugName = String(reflecting: type)
        self.qualifier = nil
    }

    init(type: Any.Type, qualifier: String?) {
        self.typeId = ObjectIdentifier(type)
        self.debugName = String(reflecting: type)
        self.qualifier = qualifier
    }

    // MARK: - Hashable & Equatable

    func hash(into hasher: inout Hasher) {
        hasher.combine(typeId)
        hasher.combine(qualifier)
    }

    static func == (
        lhs: DependencyName,
        rhs: DependencyName
    ) -> Bool {
        lhs.typeId == rhs.typeId && lhs.qualifier == rhs.qualifier
    }

    // MARK: - CustomStringConvertible

    var description: String {
        if let qualifier = qualifier {
            return "\(debugName) [qualifier=\(qualifier)]"
        }
        return debugName
    }
}
