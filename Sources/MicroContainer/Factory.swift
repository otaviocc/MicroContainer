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

/// A factory (dynamic lifetime) dependency registration.
///
/// Use in result builder syntax:
///
/// ```swift
/// let container = DependencyContainer {
///     Factory(ViewModel.self) { container in
///         ViewModel(service: container.resolve())
///     }
/// }
/// ```
public struct Factory<T>: Registration {

    // MARK: - Properties

    private let type: T.Type
    private let qualifier: String?
    private let factory: (DependencyContainer) -> T

    // MARK: - Life cycle

    /// Creates a factory registration.
    ///
    /// - Parameters:
    ///   - type: The type to register.
    ///   - qualifier: Optional qualifier for multiple registrations of the same type.
    ///   - factory: Factory closure invoked on every resolution.
    public init(
        _ type: T.Type,
        qualifier: String? = nil,
        factory: @escaping (DependencyContainer) -> T
    ) {
        self.type = type
        self.qualifier = qualifier
        self.factory = factory
    }

    // MARK: - Public

    public func apply(
        to container: DependencyContainer
    ) {
        container.registerFactory(
            type,
            qualifier: qualifier,
            factory: factory
        )
    }
}
