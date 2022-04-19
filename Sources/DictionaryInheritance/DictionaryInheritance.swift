// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/04/2022.
//  All code (c) 2022 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

public struct DictionaryIndex {
    public typealias Record = [String:Any]
    public typealias Index = [String: Record]

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
            return resolved
        }
        
        guard let raw = records[key] else { return nil }
        guard let inherits = raw["inherits"] as? [String] else {
            resolved[key] = raw
            return raw
        }
        
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
