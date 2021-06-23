//
//  BindableObject.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/06/24.
//

import Foundation

public protocol Bindable {
    associatedtype T
    var bind: ((T) -> Void)? { get set }
}


@propertyWrapper
class BindableObject<Object>: Bindable {
    var bind: ((Object) -> Void)?
    
    private var value: Object {
        didSet {
            DispatchQueue.main.async { [self] in
                self.bind?(value)
            }
        }
    }
    
    init(wrappedValue initialValue: Object) {
        self.value = initialValue
    }
    
    var wrappedValue: T {
        get { self.value }
        set { self.value = newValue }
    }
    
    var projectedValue: BindableObject {
        return self
    }
}
