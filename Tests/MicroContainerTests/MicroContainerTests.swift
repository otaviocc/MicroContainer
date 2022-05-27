import XCTest
import MicroContainer

final class MicroContainerTests: XCTestCase {
    func testProtocol() throws {
        let container = DependencyContainer()

        container.register(
            type: OvenProtocol.self,
            allocation: .static
        ) { container in
            Oven()
        }

        container.register(
            type: FridgeProtocol.self,
            allocation: .static
        ) { container in
            Fridge()
        }

        container.register(
            type: KitchenProtocol.self,
            allocation: .static
        ) { container in
            Kitchen(
                fridge: container.resolve(),
                oven: container.resolve()
            )
        }

        let kitchen: KitchenProtocol = container.resolve()

        XCTAssertTrue(kitchen.testSupport)
    }

    func testConcreteType() throws {
        let container = DependencyContainer()

        container.register(
            type: Oven.self,
            allocation: .static
        ) { container in
            Oven()
        }

        container.register(
            type: Fridge.self,
            allocation: .static
        ) { container in
            Fridge()
        }

        container.register(
            type: Kitchen.self,
            allocation: .static
        ) { container in
            Kitchen(
                fridge: container.resolve() as Fridge,
                oven: container.resolve() as Oven
            )
        }

        let kitchen: Kitchen = container.resolve()

        XCTAssertTrue(kitchen.testSupport)
    }

    func testStatic() throws {
        let container = DependencyContainer()

        container.register(
            type: Oven.self,
            allocation: .static
        ) { container in
            Oven()
        }

        container.register(
            type: Fridge.self,
            allocation: .static
        ) { container in
            Fridge()
        }

        container.register(
            type: Kitchen.self,
            allocation: .static
        ) { container in
            Kitchen(
                fridge: container.resolve() as Fridge,
                oven: container.resolve() as Oven
            )
        }

        let kitchen: Kitchen = container.resolve()
        let anotherKitchen: Kitchen = container.resolve()

        XCTAssert(kitchen === anotherKitchen)
    }

    func testDynamic() throws {
        let container = DependencyContainer()

        container.register(
            type: Oven.self,
            allocation: .dynamic
        ) { container in
            Oven()
        }

        container.register(
            type: Fridge.self,
            allocation: .dynamic
        ) { container in
            Fridge()
        }

        container.register(
            type: Kitchen.self,
            allocation: .dynamic
        ) { container in
            Kitchen(
                fridge: container.resolve() as Fridge,
                oven: container.resolve() as Oven
            )
        }

        let kitchen: Kitchen = container.resolve()
        let anotherKitchen: Kitchen = container.resolve()

        XCTAssert(kitchen !== anotherKitchen)
    }
}
