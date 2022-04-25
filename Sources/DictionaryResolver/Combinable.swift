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
        guard type(of: other) == type(of: self) else { return self }
        return (other as! Self) + self
    }
}

extension NSArray: Combinable {
    public func combine(with other: Any, combiner: Combiner) -> Any {
        guard type(of: other) == type(of: self) else { return self }
        return (other as! [Any]) + (self as! [Any])
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
