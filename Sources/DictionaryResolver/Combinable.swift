// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 25/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public protocol Combinable {
    func combine(with other: Any, combiner: Combiner) -> Any
}

extension Array: Combinable {
    public func combine(with other: Any, combiner: Combiner) -> Any {
        guard let other = other as? Self else { return self }

        let combined = other + self
        return combined
    }
}

extension NSArray: Combinable {
    public func combine(with other: Any, combiner: Combiner) -> Any {
        guard let existing = self as? [Any], let other = other as? [Any] else { return self }

        let combined = other + existing
        return combined
    }
    
}

extension Dictionary: Combinable {
    public func combine(with other: Any, combiner: Combiner) -> Any {
        guard type(of: other) == type(of: self) else { return self }
        return self.merging(other as! Self, uniquingKeysWith: { existing, new in
            combiner.combine(existing, new)
        })
    }
}
