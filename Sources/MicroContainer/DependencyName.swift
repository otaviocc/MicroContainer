struct DependencyName: Equatable, Hashable, CustomStringConvertible {

    // MARK: - Properties

    private let typeId: ObjectIdentifier
    private let debugName: String

    // MARK: - Life cycle

    init(type: Any.Type) {
        self.typeId = ObjectIdentifier(type)
        self.debugName = String(reflecting: type)
    }

    // MARK: - Hashable & Equatable

    func hash(into hasher: inout Hasher) {
        hasher.combine(typeId)
    }

    static func == (
        lhs: DependencyName,
        rhs: DependencyName
    ) -> Bool {
        lhs.typeId == rhs.typeId
    }

    // MARK: - CustomStringConvertible

    var description: String { debugName }
}
