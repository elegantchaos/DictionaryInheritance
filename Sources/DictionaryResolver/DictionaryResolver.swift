// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/04/2022.
//  All code (c) 2022 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CollectionExtensions
import Foundation

public struct DictionaryResolver {
    public typealias Record = [String:Any]
    public typealias Index = [String: Record]
    public typealias Combiner = (Any, Any) -> Any

    let inheritanceKey: String
    let resolvingKey: String
    private static let resolvingSentinel = ResolvingSentinel()
    
    /// Unprocessed records.
    var records: Index
    
    /// Resolved records.
    var resolved: Index
    
    /// Custom combining functions, stored by key.
    var combineByKey: [String: Combiner]
    
    /// Custom combining functions, stored by record type.
    var combineByType: [String: Combiner]

    var merger: (inout Record, Record) -> ()

    /// Create with an existing set of records.
    public init(_ records: Index = [:], inheritanceKey: String = "inherits", resolvingKey: String = "«resolving»") {
        self.records = records
        self.resolved = [:]
        self.combineByKey = [:]
        self.combineByType = [:]
        self.inheritanceKey = inheritanceKey
        self.resolvingKey = resolvingKey
        self.merger = Self.simpleMerge
    }
    
    /// Add a record to the index.
    public mutating func add(_ record: Record, withID id: String) {
        records[id] = record
    }
    
    /// Add some records to the index.
    public mutating func add(_ newRecords: Index) {
        records.mergeReplacingDuplicates(newRecords)
    }
    
    /// Add a record to the index from a file.
    public mutating func loadRecord(from url: URL) throws {
        let data = try Data(contentsOf: url)
        if let record = try JSONSerialization.jsonObject(with: data) as? DictionaryResolver.Record {
            add(record, withID: url.deletingPathExtension().lastPathComponent)
        }
    }

    /// Add some records to the index from a file.
    public mutating func loadRecords(from url: URL) throws {
        let data = try Data(contentsOf: url)
        if let records = try JSONSerialization.jsonObject(with: data) as? DictionaryResolver.Index {
            add(records)
        }
    }
    
    /// Resolve all unresolved records.
    public mutating func resolve() {
        let useCustomMerger = (combineByKey.count > 0) || (combineByType.count > 0)
        merger = useCustomMerger ? customMerge : Self.simpleMerge
        
        // for valid sets of records the order we merge in makes no difference, but if there
        // are loops, then the order determines which merge succeeds and which one fails
        // therefore we sort the keys so that the order of merging is deterministic
        let sortedKeys = records.keys.sorted()
        for key in sortedKeys {
            _ = resolve(key: key)
        }
    }

    /// Returns the resolved record with a given key (if there is one).
    /// If there is no resolved record, returns the unresolved if it exists.
    public func record(withID id: String) -> Record? {
        resolved[id] ?? records[id]
    }
    
    /// Remove all records.
    public mutating func removeAll() {
        resolved.removeAll()
        records.removeAll()
    }
    
    /// Retain all records, but reset them to their unresolved state.
    public mutating func reset() {
        resolved.removeAll()
    }

    public static func stringListMerge(_ existing: Any, _ inherited: Any) -> Any {
        if let existingList = existing as? [String], let inheritedList = inherited as? [String] {
            return inheritedList + existingList
        } else {
            return existing
        }
    }

    public static func stringListMerge2(_ existingList: [String], _ inheritedList: [String]) -> [String] {
        return inheritedList + existingList
    }

}

private extension DictionaryResolver {
    /// Placeholder which indicates that a record is being resolved.
    /// Used to prevent loops during resolution.
    class ResolvingSentinel {
    }

    /// Resolve a single record.
    /// If it is has already been processed, we just return the resolved value.
    /// If not, we process any inherited properties.
    /// We mark it as in-progress before we start processing, so that we can detect loops.
    mutating func resolve(key: String) -> Record? {
        if let resolved = resolved[key] {
            if (resolved.count == 1) && (resolved[resolvingKey] as? ResolvingSentinel === Self.resolvingSentinel) {
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
        
        // guard against recursion; if this key is used whilst resolving the inherited keys,
        // the resolution process will safely unwind, and a warning will be emitted
        resolved[key] = [resolvingKey:Self.resolvingSentinel]
        
        var merged = raw
        for inheritedKey in inherits {
            if let inheritedValues = resolve(key: inheritedKey) {
                merger(&merged, inheritedValues)
            } else {
                print("missing record \(inheritedKey)")
            }
        }
        
        resolved[key] = merged
        return merged
    }
    
    static func simpleMerge(_ record: inout Record, with newRecord: Record) {
        record.merge(newRecord, uniquingKeysWith: { existing, new in existing })
    }
    
    func customMerge(_ record: inout Record, with newRecord: Record) {
        for key in record.keys {
            if let existing = record[key] {
                if let new = newRecord[key] {
                    if let combiner = combineByKey[key] {
                        record[key] = combiner(existing, new)
                    } else {
                        let t = type(of: existing)
                        if t == type(of: new), let combiner = combineByType[String(describing: t)] {
                            record[key] = combiner(existing, new)
                        }
                    }
                }
            } else if let new = newRecord[key] {
                record[key] = new
            }
        }
    }
    
    func combinerForKey(_ key: String) -> (Any, Any) -> Any {
        return combineByKey[key] ?? { existing, new in
        }
    }
}
