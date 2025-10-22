import MicroContainer
import Testing

@MainActor
struct ResultBuilderTests {

    @Test
    func basicSingletonRegistration() async throws {
        let container = DependencyContainer {
            Singleton(Oven.self) { _ in
                Oven()
            }
        }

        let oven: Oven = container.resolve()
        let anotherOven: Oven = container.resolve()

        #expect(
            oven === anotherOven,
            "It should return same instance for singleton"
        )
    }

    @Test
    func basicFactoryRegistration() async throws {
        let container = DependencyContainer {
            Factory(Oven.self) { _ in
                Oven()
            }
        }

        let oven: Oven = container.resolve()
        let anotherOven: Oven = container.resolve()

        #expect(
            oven !== anotherOven,
            "It should return new instance each time for factory"
        )
    }

    @Test
    func multipleDependencies() async throws {
        let container = DependencyContainer {
            Singleton(Oven.self) { _ in
                Oven()
            }
            Singleton(Fridge.self) { _ in
                Fridge()
            }
            Singleton(Kitchen.self) { container in
                Kitchen(
                    fridge: container.resolve() as Fridge,
                    oven: container.resolve() as Oven
                )
            }
        }

        let kitchen: Kitchen = container.resolve()

        #expect(
            kitchen.testSupport == true,
            "It should resolve dependency graph successfully"
        )
    }

    @Test
    func protocolRegistration() async throws {
        let container = DependencyContainer {
            Singleton(OvenProtocol.self) { _ in
                Oven()
            }
            Singleton(FridgeProtocol.self) { _ in
                Fridge()
            }
            Singleton(KitchenProtocol.self) { container in
                Kitchen(
                    fridge: container.resolve(),
                    oven: container.resolve()
                )
            }
        }

        let kitchen: KitchenProtocol = container.resolve()

        #expect(
            kitchen.testSupport == true,
            "It should resolve protocol-typed dependencies"
        )
    }

    @Test
    func qualifiedDependencies() async throws {
        let container = DependencyContainer {
            Singleton(ClientProtocol.self, qualifier: "primary") { _ in
                PrimaryClient()
            }
            Singleton(ClientProtocol.self, qualifier: "staging") { _ in
                StagingClient()
            }
        }

        let primary: ClientProtocol = container.resolve(qualifier: "primary")
        let staging: ClientProtocol = container.resolve(qualifier: "staging")

        #expect(
            primary is PrimaryClient,
            "It should resolve primary qualified client"
        )
        #expect(
            staging is StagingClient,
            "It should resolve staging qualified client"
        )
    }

    @Test
    func mixedSingletonAndFactory() async throws {
        let container = DependencyContainer {
            Singleton(Oven.self) { _ in
                Oven()
            }
            Factory(Fridge.self) { _ in
                Fridge()
            }
        }

        let oven1: Oven = container.resolve()
        let oven2: Oven = container.resolve()
        let fridge1: Fridge = container.resolve()
        let fridge2: Fridge = container.resolve()

        #expect(
            oven1 === oven2,
            "It should return same instance for singleton"
        )
        #expect(
            fridge1 !== fridge2,
            "It should return different instances for factory"
        )
    }

    @Test
    func emptyContainer() async throws {
        let container = DependencyContainer {}

        #expect(
            container.contains(Oven.self) == false,
            "It should have no registrations when container is empty"
        )
    }

    @Test
    func multipleQualifiedRegistrations() async throws {
        let container = DependencyContainer {
            Singleton(Oven.self, qualifier: "oven1") { _ in
                Oven()
            }
            Singleton(Oven.self, qualifier: "oven2") { _ in
                Oven()
            }
            Singleton(Oven.self, qualifier: "oven3") { _ in
                Oven()
            }
        }

        #expect(
            container.contains(Oven.self, qualifier: "oven1"),
            "It should register oven1"
        )
        #expect(
            container.contains(Oven.self, qualifier: "oven2"),
            "It should register oven2"
        )
        #expect(
            container.contains(Oven.self, qualifier: "oven3"),
            "It should register oven3"
        )
    }

    @Test
    func nestedResolution() async throws {
        let container = DependencyContainer {
            Factory(Oven.self) { _ in
                Oven()
            }
            Factory(Fridge.self) { _ in
                Fridge()
            }
            Factory(Kitchen.self) { container in
                Kitchen(
                    fridge: container.resolve() as Fridge,
                    oven: container.resolve() as Oven
                )
            }
        }

        let kitchen1: Kitchen = container.resolve()
        let kitchen2: Kitchen = container.resolve()

        #expect(
            kitchen1 !== kitchen2,
            "It should create new Kitchen instances for factory"
        )
        #expect(
            kitchen1.testSupport == true,
            "It should resolve nested dependencies"
        )
    }

    @Test
    func moreThanSixRegistrations() async throws {
        // Test that buildPartialBlock allows unlimited registrations
        let container = DependencyContainer {
            Singleton(Oven.self, qualifier: "1") { _ in Oven() }
            Singleton(Oven.self, qualifier: "2") { _ in Oven() }
            Singleton(Oven.self, qualifier: "3") { _ in Oven() }
            Singleton(Oven.self, qualifier: "4") { _ in Oven() }
            Singleton(Oven.self, qualifier: "5") { _ in Oven() }
            Singleton(Oven.self, qualifier: "6") { _ in Oven() }
            Singleton(Oven.self, qualifier: "7") { _ in Oven() }
            Singleton(Oven.self, qualifier: "8") { _ in Oven() }
            Singleton(Oven.self, qualifier: "9") { _ in Oven() }
            Singleton(Oven.self, qualifier: "10") { _ in Oven() }
        }

        #expect(
            container.contains(Oven.self, qualifier: "1"),
            "It should register dependency 1"
        )
        #expect(
            container.contains(Oven.self, qualifier: "6"),
            "It should register dependency 6"
        )
        #expect(
            container.contains(Oven.self, qualifier: "7"),
            "It should register dependency 7 (beyond old limit)"
        )
        #expect(
            container.contains(Oven.self, qualifier: "10"),
            "It should register dependency 10 (beyond old limit)"
        )
    }
}
