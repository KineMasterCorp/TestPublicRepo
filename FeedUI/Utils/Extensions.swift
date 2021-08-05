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
