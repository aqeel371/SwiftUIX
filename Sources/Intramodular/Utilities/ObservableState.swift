//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A @State-like property wrapper that offers affordances for observing value changes as a stream of publisher events.
@propertyWrapper
public struct ObservableState<Value>: DynamicProperty {
    public typealias ValueChange = (oldValue: Value, newValue: Value)
    
    private var _willChange: PassthroughSubject<ValueChange, Never>
    private var _didChange: PassthroughSubject<ValueChange, Never>
    
    @State private var _wrappedValue: (previous: Value?, current: Value)
    
    /// An observable stream of value changes, before they happen.
    public var willChange: AnyPublisher<ValueChange, Never> {
        return _willChange.eraseToAnyPublisher()
    }
    
    /// An observable stream of value changes, after they happen.
    public var didChange: AnyPublisher<ValueChange, Never> {
        return _didChange.eraseToAnyPublisher()
    }
    
    /// The current state value.
    public var wrappedValue: Value {
        get {
            _wrappedValue.current
        } nonmutating set {
            let current = _wrappedValue.current
            
            defer {
                _didChange.send((current, newValue))
            }
            
            _willChange.send((current, newValue))
            
            _wrappedValue = (_wrappedValue.current, newValue)
        }
    }
    
    /// Initialize with the provided initial value.
    public init(wrappedValue value: Value) {
        self._willChange = .init()
        self._didChange = .init()
        self.__wrappedValue = .init(initialValue: (nil, value))
    }
    
    public mutating func update() {
        self.__wrappedValue.update()
    }
    
    /// Returns a binding referencing the state value.
    public var binding: Binding<Value> {
        return .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
}
