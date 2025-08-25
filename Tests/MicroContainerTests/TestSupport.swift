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

// MARK: - Client (for qualifier tests)

protocol ClientProtocol {}
class PrimaryClient: ClientProtocol {}
class StagingClient: ClientProtocol {}

// MARK: - Counter (for warmSingletons)

@MainActor
class Counter {
    static var initCount = 0
    init() { Counter.initCount += 1 }
}

// MARK: - Cyclic types

class TypeA {}
class TypeB {}

// Observability helper for cycle tests
@MainActor
enum CycleObserver {
    static var sawCycle = false
}
