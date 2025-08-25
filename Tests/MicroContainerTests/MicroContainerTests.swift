import XCTest
import MicroContainer

@MainActor
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

        XCTAssertTrue(
            kitchen.testSupport,
            "It should resolve a protocol-typed dependency graph successfully"
        )
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

        XCTAssertTrue(
            kitchen.testSupport,
            "It should resolve a concrete-typed dependency graph successfully"
        )
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

        XCTAssertTrue(
            kitchen === anotherKitchen,
            "It should return the same instance for static allocation"
        )
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

        XCTAssertTrue(
            kitchen !== anotherKitchen,
            "It should return a new instance for dynamic allocation"
        )
    }

    func testQualifiers() throws {
        let container = DependencyContainer()

        container.registerSingleton(
            ClientProtocol.self,
            qualifier: "primary"
        ) { _ in
            PrimaryClient()
        }
        container.registerSingleton(
            ClientProtocol.self,
            qualifier: "staging"
        ) { _ in
            StagingClient()
        }

        let primary: ClientProtocol = container.resolve(
            qualifier: "primary"
        )
        let staging: ClientProtocol = container.resolve(
            qualifier: "staging"
        )

        XCTAssertTrue(
            primary is PrimaryClient,
            "It should resolve the primary qualified client"
        )
        XCTAssertTrue(
            staging is StagingClient,
            "It should resolve the staging qualified client"
        )

        XCTAssertTrue(
            container.contains(
                ClientProtocol.self,
                qualifier: "primary"
            ),
            "It should report primary client registration exists"
        )
        XCTAssertTrue(
            container.contains(
                ClientProtocol.self,
                qualifier: "staging"
            ),
            "It should report staging client registration exists"
        )

        container.unregister(
            ClientProtocol.self,
            qualifier: "staging"
        )
        XCTAssertFalse(
            container.contains(
                ClientProtocol.self,
                qualifier: "staging"
            ),
            "It should report staging client registration removed after unregister"
        )
        XCTAssertNotNil(
            container.resolveOptional(
                qualifier: "primary"
            ) as ClientProtocol?,
            "It should still resolve the primary client optionally"
        )
        XCTAssertNil(
            container.resolveOptional(
                qualifier: "staging"
            ) as ClientProtocol?,
            "It should not resolve the staging client after unregister"
        )
    }

    func testResolveOptionalAndThrowing() {
        let container = DependencyContainer()

        XCTAssertNil(
            container.resolveOptional() as String?,
            "It should return nil for missing registrations with resolveOptional"
        )
        XCTAssertThrowsError(
            try container.resolveOrThrow() as String,
            "It should throw notRegistered for missing type"
        ) { error in
            guard case DependencyContainer.ResolutionError.notRegistered(let type) = error else {
                return XCTFail("Unexpected error: \(error)")
            }
            XCTAssertTrue(
                String(describing: type).contains("String"),
                "It should mention the missing type in the error payload"
            )
        }

        container.registerFactory(
            String.self
        ) { _ in
            "hello"
        }
        XCTAssertEqual(
            container.resolveOptional() as String?,
            "hello",
            "It should resolve the registered factory value via resolveOptional"
        )
        XCTAssertEqual(
            try? container.resolveOrThrow() as String,
            "hello",
            "It should resolve the registered factory value via resolveOrThrow"
        )
    }

    func testResetAndWarmSingletons() {
        let container = DependencyContainer()
        Counter.initCount = 0
        container.registerSingleton(
            Counter.self
        ) { _ in
            Counter()
        }

        // warm should instantiate once
        container.warmSingletons()
        XCTAssertEqual(
            Counter.initCount,
            1,
            "It should warm exactly one singleton instance"
        )

        // resolved instance should be the warmed one
        let firstCounter: Counter = container.resolve()
        let secondCounter: Counter = container.resolve()
        XCTAssertTrue(
            firstCounter === secondCounter,
            "It should return the pre-warmed singleton instance on resolve"
        )
        XCTAssertEqual(
            Counter.initCount,
            1,
            "It should not create additional instances when resolving a warmed singleton"
        )

        // reset clears all
        container.reset()
        XCTAssertFalse(
            container.contains(Counter.self),
            "It should clear registrations after reset"
        )
        Counter.initCount = 0
    }

    func testCircularDetection() {
        let container = DependencyContainer()
        CycleObserver.sawCycle = false
        container.registerFactory(
            TypeA.self
        ) { container in
            // A depends on B
            let maybeTypeB: TypeB? = container.resolveOptional()
            if maybeTypeB == nil { CycleObserver.sawCycle = true }
            return TypeA()
        }
        container.registerFactory(
            TypeB.self
        ) { container in
            // B depends on A
            let maybeTypeA: TypeA? = container.resolveOptional()
            if maybeTypeA == nil { CycleObserver.sawCycle = true }
            return TypeB()
        }

        // Resolve still succeeds because factories tolerate missing deps,
        // but the cycle was detected in optional resolution.
        let _: TypeA = container.resolve()
        XCTAssertTrue(
            CycleObserver.sawCycle,
            "It should detect the cycle during optional nested resolutions"
        )
    }
}
