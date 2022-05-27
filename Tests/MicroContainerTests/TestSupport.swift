// MARK: - Oven

protocol OvenProtocol {}
class Oven: OvenProtocol {}

// MARK: - Fridge

protocol FridgeProtocol {}
class Fridge: FridgeProtocol {}

// MARK: - Kitchen

protocol KitchenProtocol {
    var testSupport: Bool { get }
}
class Kitchen: KitchenProtocol {
    let fridge: FridgeProtocol
    let oven: OvenProtocol
    var testSupport = true

    init(
        fridge: FridgeProtocol,
        oven: OvenProtocol
    ) {
        self.fridge = fridge
        self.oven = oven
    }
}
