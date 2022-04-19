// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/04/2022.
//  All code (c) 2022 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

public struct DictionaryIndex {
    public typealias Record = [String:Any]
    public typealias Index = [String: Record]

    class ResolvingSentinel {
    }
    
    let inheritanceKey = "inherits"
    let resolvingKey = "«resolving»"
    let resolvingSentinel = ResolvingSentinel()
    
    var records: Index
    
    init(_ records: Index) {
        self.records = records
    }
    
    mutating func resolve() {
        var resolved: Index = [:]
        for key in records.keys {
            _ = resolve(key: key, into: &resolved)
        }
        records = resolved
    }
    
    func resolve(key: String, into resolved: inout Index) -> Record? {
        if let resolved = resolved[key] {
            if (resolved.count == 1) && (resolved[resolvingKey] as? ResolvingSentinel === resolvingSentinel) {
                print("loop detected for record \(key)")
                return [:]
            }

            return resolved
        }
        
        guard let raw = records[key] else { return nil }
        guard let inherits = raw[inheritanceKey] as? [String] else {
            resolved[key] = raw
            return raw
        }
        
        resolved[key] = [resolvingKey:resolvingSentinel] // guard against recursion

        var merged = raw
        for inheritedKey in inherits {
            if let inhertedValues = resolve(key: inheritedKey, into: &resolved) {
                merged.merge(inhertedValues, uniquingKeysWith: { existing, new in new })
            } else {
                print("missing record \(inheritedKey)")
            }
        }
        
        resolved[key] = merged
        return merged
    }
    func record(withID id: String) -> Record? {
        records[id]
    }
}
