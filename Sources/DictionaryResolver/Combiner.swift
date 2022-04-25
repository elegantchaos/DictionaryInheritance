// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 25/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct Combiner {
    public enum Result {
        case notCombined
        case combined(Any)
    }
    
    public typealias Processor = (Any, Any, Combiner) -> Result

    var processors: [Processor]

    public init() {
        processors = []
    }
    
    public mutating func append(_ combiner: @escaping Processor) {
        processors.append(combiner)
    }
    
    public func combine<T>(_ existing: T, _ new: T) -> T {
        for combiner in processors {
            switch combiner(existing, new, self) {
                case .combined(let result): return result as! T
                case .notCombined: break
            }
        }

        return existing
    }
    
    /// Standard combiner which merges two combinble types together.
    public static func combineCombinable(_ existing: Any, _ inherited: Any, combiner: Combiner) -> Combiner.Result {
        guard let existing = existing as? Combinable, let inherited = inherited as? Combinable else {
            return .notCombined
        }

        return .combined(existing.combine(with: inherited, combiner: combiner))
    }
}
