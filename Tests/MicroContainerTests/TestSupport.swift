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
    init() {
        Counter.initCount += 1
    }
}

// MARK: - Cyclic types

class TypeA {}
class TypeB {}

/// Observability helper for cycle tests
@MainActor
enum CycleObserver {

    static var sawCycle = false
}
