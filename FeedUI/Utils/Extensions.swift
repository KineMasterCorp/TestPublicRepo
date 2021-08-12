//
//  extensions.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/06/08.
//

import Foundation

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

extension Bool {
    mutating func signal() {
        self.toggle()
    }
}

extension Double {
    func format(_ form: String) -> String {
        String(format: form, self)
    }
    
    var formatted: String {
        format("%.3f")
    }
}

extension Array where Element : Equatable {
    public subscript(safe bounds: Range<Int>) -> ArraySlice<Element> {
        if bounds.lowerBound > count { return [] }
        let lower = Swift.max(0, bounds.lowerBound)
        let upper = Swift.max(0, Swift.min(count, bounds.upperBound))
        return self[lower..<upper]
    }
}
