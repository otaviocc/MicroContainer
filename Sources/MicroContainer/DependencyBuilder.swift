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

/// A result builder for declarative dependency container configuration.
///
/// Enables SwiftUI-like syntax for registering dependencies:
///
/// ```swift
/// let container = DependencyContainer {
///     Singleton(Logger.self) { _ in Logger() }
///     Singleton(HTTPClient.self) { _ in HTTPClient() }
///     Factory(ViewModel.self) { container in
///         ViewModel(service: container.resolve())
///     }
/// }
/// ```
@resultBuilder
public enum DependencyBuilder {

    /// Builds an empty block.
    ///
    /// Required for empty container initialization: `DependencyContainer {}`
    public static func buildBlock() -> [Registration] {
        []
    }

    /// Converts a single registration into a partial result array.
    ///
    /// This is the entry point for building up registrations incrementally.
    public static func buildPartialBlock(
        first: Registration
    ) -> [Registration] {
        [first]
    }

    /// Accumulates registrations into the partial result array.
    ///
    /// Each subsequent registration is appended to the accumulated array.
    /// This allows unlimited registrations without overload limits.
    public static func buildPartialBlock(
        accumulated: [Registration],
        next: Registration
    ) -> [Registration] {
        accumulated + [next]
    }

    /// Builds an optional registration block.
    public static func buildOptional(
        _ component: [Registration]?
    ) -> [Registration] {
        component ?? []
    }

    /// Builds the first branch of a conditional.
    public static func buildEither(
        first component: [Registration]
    ) -> [Registration] {
        component
    }

    /// Builds the second branch of a conditional.
    public static func buildEither(
        second component: [Registration]
    ) -> [Registration] {
        component
    }

    /// Builds limited availability.
    public static func buildLimitedAvailability(
        _ component: [Registration]
    ) -> [Registration] {
        component
    }

    /// Builds an array of registrations from a loop.
    public static func buildArray(
        _ components: [Registration]
    ) -> [Registration] {
        components
    }
}
