// MIT License
//
// Copyright (c) 2026 Otávio C.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import MicroContainer
import Testing

// swiftlint:disable type_body_length

@MainActor
struct MicroContainerTests {

    @Test
    func `protocol`() {
        let container = DependencyContainer()

        container.register(
            type: OvenProtocol.self,
            allocation: .static
        ) { _ in
            Oven()
        }

        container.register(
            type: FridgeProtocol.self,
            allocation: .static
        ) { _ in
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

        #expect(
            kitchen.testSupport == true,
            "It should resolve a protocol-typed dependency graph successfully"
        )
    }

    @Test
    func concreteType() {
        let container = DependencyContainer()

        container.register(
            type: Oven.self,
            allocation: .static
        ) { _ in
            Oven()
        }

        container.register(
            type: Fridge.self,
            allocation: .static
        ) { _ in
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

        #expect(
            kitchen.testSupport == true,
            "It should resolve a concrete-typed dependency graph successfully"
        )
    }

    @Test
    func `static`() {
        let container = DependencyContainer()

        container.register(
            type: Oven.self,
            allocation: .static
        ) { _ in
            Oven()
        }

        container.register(
            type: Fridge.self,
            allocation: .static
        ) { _ in
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

        #expect(
            kitchen === anotherKitchen,
            "It should return the same instance for static allocation"
        )
    }

    @Test
    func dynamic() {
        let container = DependencyContainer()

        container.register(
            type: Oven.self,
            allocation: .dynamic
        ) { _ in
            Oven()
        }

        container.register(
            type: Fridge.self,
            allocation: .dynamic
        ) { _ in
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

        #expect(
            kitchen !== anotherKitchen,
            "It should return a new instance for dynamic allocation"
        )
    }

    // swiftlint:disable function_body_length
    @Test
    func qualifiers() {
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

        #expect(
            primary is PrimaryClient,
            "It should resolve the primary qualified client"
        )
        #expect(
            staging is StagingClient,
            "It should resolve the staging qualified client"
        )

        #expect(
            container.contains(ClientProtocol.self, qualifier: "primary"),
            "It should report primary client registration exists"
        )
        #expect(
            container.contains(ClientProtocol.self, qualifier: "staging"),
            "It should report staging client registration exists"
        )

        container.unregister(
            ClientProtocol.self,
            qualifier: "staging"
        )
        #expect(
            container.contains(ClientProtocol.self, qualifier: "staging") == false,
            "It should report staging client registration removed after unregister"
        )
        #expect(
            (container.resolveOptional(qualifier: "primary") as ClientProtocol?) != nil,
            "It should still resolve the primary client optionally"
        )
        #expect(
            (container.resolveOptional(qualifier: "staging") as ClientProtocol?) == nil,
            "It should not resolve the staging client after unregister"
        )
    }

    // swiftlint:enable function_body_length

    @Test
    func resolveOptionalAndThrowing() throws {
        let container = DependencyContainer()

        #expect(
            (container.resolveOptional() as String?) == nil,
            "It should return nil for missing registrations with resolveOptional"
        )

        #expect(throws: DependencyContainer.ResolutionError.self) {
            try container.resolveOrThrow() as String
        }

        container.registerFactory(
            String.self
        ) { _ in
            "hello"
        }
        #expect(
            container.resolveOptional() == "hello",
            "It should resolve the registered factory value via resolveOptional"
        )
        #expect(
            try container.resolveOrThrow() == "hello",
            "It should resolve the registered factory value via resolveOrThrow"
        )
    }

    @Test
    func resetAndWarmSingletons() {
        let container = DependencyContainer()
        Counter.initCount = 0
        container.registerSingleton(
            Counter.self
        ) { _ in
            Counter()
        }

        container.warmSingletons()
        #expect(
            Counter.initCount == 1,
            "It should warm exactly one singleton instance"
        )

        let firstCounter: Counter = container.resolve()
        let secondCounter: Counter = container.resolve()
        #expect(
            firstCounter === secondCounter,
            "It should return the pre-warmed singleton instance on resolve"
        )
        #expect(
            Counter.initCount == 1,
            "It should not create additional instances when resolving a warmed singleton"
        )

        container.reset()
        #expect(
            container.contains(Counter.self) == false,
            "It should clear registrations after reset"
        )
        Counter.initCount = 0
    }

    @Test
    func circularDetection() {
        let container = DependencyContainer()
        CycleObserver.sawCycle = false

        container.registerFactory(
            TypeA.self
        ) { container in
            let maybeTypeB: TypeB? = container.resolveOptional()
            if maybeTypeB == nil { CycleObserver.sawCycle = true }
            return TypeA()
        }

        container.registerFactory(
            TypeB.self
        ) { container in
            let maybeTypeA: TypeA? = container.resolveOptional()
            if maybeTypeA == nil { CycleObserver.sawCycle = true }
            return TypeB()
        }

        let _: TypeA = container.resolve()
        #expect(
            CycleObserver.sawCycle == true,
            "It should detect the cycle during optional nested resolutions"
        )
    }
}

// swiftlint:enable type_body_length
