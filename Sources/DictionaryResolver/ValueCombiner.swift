// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 25/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct Combiners {
    public enum CombineResult {
        case notCombined
        case combined(Any)
    }
    
    public typealias Combiner = (Any, Any, Combiners) -> CombineResult

    var combiners: [Combiner]

    public init() {
        combiners = []
    }
    
    public mutating func append(_ combiner: @escaping Combiner) {
        combiners.append(combiner)
    }
    
    public func combine<T>(_ existing: T, _ new: T) -> T {
        for combiner in combiners {
            switch combiner(existing, new, self) {
                case .combined(let result): return result as! T
                case .notCombined: break
            }
        }

        return existing
    }
    
    /// Standard combiner which merges two lists together.
    /// It only runs if both lists are of the same type.
    public static func combineCombinable(_ existing: Any, _ inherited: Any, combiners: Combiners) -> Combiners.CombineResult {
        guard let existing = existing as? Combinable, let inherited = inherited as? Combinable else {
            return .notCombined
        }

        return .combined(existing.combine(with: inherited, combiners: combiners))
    }
}
