struct DependencyName: RawRepresentable, Equatable, Hashable {

    // MARK: - Properties

    let rawValue: String

    // MARK: - Life cycle

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(type: Any.Type) {
        self.rawValue = String(describing: type)
    }
}
