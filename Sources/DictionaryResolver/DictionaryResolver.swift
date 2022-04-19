// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/04/2022.
//  All code (c) 2022 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CollectionExtensions
import Foundation

public struct DictionaryResolver {
    public typealias Record = [String:Any]
    public typealias Index = [String: Record]

    let inheritanceKey = "inherits"
    let resolvingKey = "«resolving»"
    private static let resolvingSentinel = ResolvingSentinel()
    
    var records: Index
    var resolved: Index
    
    /// Create with an existing set of records.
    public init(_ records: Index = [:]) {
        self.records = records
        self.resolved = [:]
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
            add(records, withID: url.deletingPathExtension().lastPathComponent)
        }
    }
    
    /// Resolve all unresolved records.
    public mutating func resolve() {
        for key in records.keys {
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
}

private extension DictionaryResolver {
    /// Placeholder which indicates that a record is being resolved.
    /// Used to prevent loops during resolution.
    class ResolvingSentinel {
    }

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
            if let inhertedValues = resolve(key: inheritedKey) {
                merged.merge(inhertedValues, uniquingKeysWith: { existing, new in existing })
            } else {
                print("missing record \(inheritedKey)")
            }
        }
        
        resolved[key] = merged
        return merged
    }
    
}
