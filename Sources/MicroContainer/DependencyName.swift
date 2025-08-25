struct DependencyName: Equatable, Hashable {

    // MARK: - Properties

    private let typeId: ObjectIdentifier

    // MARK: - Life cycle

    init(type: Any.Type) {
        self.typeId = ObjectIdentifier(type)
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
}
