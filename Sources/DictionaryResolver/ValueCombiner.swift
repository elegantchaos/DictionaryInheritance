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
    
    public typealias Combiner = (Any, Any) -> CombineResult

    var combiners: [Combiner]

    public init() {
        combiners = []
    }
    
    public mutating func append(_ combiner: @escaping Combiner) {
        combiners.append(combiner)
    }
    
    public func combine(_ existing: Any, _ new: Any) -> Any {
        for combiner in combiners {
            switch combiner(existing, new) {
                case .combined(let result): return result
                case .notCombined: break
            }
        }
        
        return existing
    }
    
    /// Standard combiner which merges two lists of strings together.
    /// It only runs if both the current and inherited values for the key are of type `Array<String>`.
    public static func combineStringLists(_ existing: Any, _ inherited: Any) -> Combiners.CombineResult {
        guard let existing = existing as? [String], let inherited = inherited as? [String] else {
            return .notCombined
        }
        
        return .combined(inherited + existing)
    }
}
