// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/04/2022.
//  All code (c) 2022 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CollectionExtensions
import Foundation
import JSONExtensions

public struct DictionaryResolver {
    public typealias Record = [String:Any]
    public typealias Index = [String: Record]
    public typealias Combiner = (String, inout Record, Record) -> Bool

    let inheritanceKey: String
    let resolvingKey: String
    private static let resolvingSentinel = ResolvingSentinel()
    
    /// Unprocessed records.
    var records: Index
    
    /// Resolved records.
    var resolved: Index
    
    /// Custom combining functions, stored by key.
    var customCombiners: [Combiner]
    
    var merger: (inout Record, Record) -> ()

    /// Create with an existing set of records.
    public init(_ records: Index = [:], inheritanceKey: String = "inherits", resolvingKey: String = "«resolving»") {
        self.records = records
        self.resolved = [:]
        self.customCombiners = []
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
    
    /// Register a custom function to combine values.
    public mutating func addCombiner(_ combiner: @escaping Combiner) {
        customCombiners.append(combiner)
    }

    /// Register a custom function to combine values which is only applied to certain keys.
    public mutating func addCombinerForKeys(_ keys: Set<String>, _ combiner: @escaping Combiner) {
        addCombiner { key, existing, inherited in
            guard keys.contains(key) else { return false }
            return combiner(key, &existing, inherited)
        }
    }

    public enum LoadMode {
        case oneRecordPerFile
        case multipleRecordsPerFile
    }
    
    /// Add some records to the index from a file.
    public mutating func loadRecords(from url: URL, mode: LoadMode = .oneRecordPerFile, idPrefix: String = "") throws {
        if url.hasDirectoryPath {
            try loadRecords(fromFolder: url, mode: mode, idPrefix: idPrefix)
        } else {
            try loadRecords(fromFile: url, mode: mode, idPrefix: idPrefix)
        }
    }
    

    /// Resolve all unresolved records.
    public mutating func resolve() {
        // use a simple merge function if we can, as it's faster
        merger = customCombiners.isEmpty ? Self.simpleMerge : customMerge
        
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
    
    /// Returns all of the resolved records.
    public var resolvedRecords: Index {
        return resolved
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

    /// Standard combiner which merges two lists of strings together.
    /// It only runs if both the current and inherited values for the key are of type `Array<String>`.
    public static func combineStringLists(_ key: String, _ existing: inout Record, _ inherited: Record) -> Bool {
        guard let existingList = existing[key] as? [String], let inheritedList = inherited[key] as? [String] else {
            return false
        }
        
        existing[key] = inheritedList + existingList
        return true
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

    /// Merge in any keys from an inherited record.
    /// If the property already exists, we keep that value and ignore the inherited one.
    static func simpleMerge(_ record: inout Record, with inheritedRecord: Record) {
        record.merge(inheritedRecord, uniquingKeysWith: { existing, new in existing })
    }

    /// Merge in any keys from an inherited record, using the custom combiners.
    /// We sort the keys so that the combiners can predict the order in which properties
    /// will be merged.
    func customMerge(_ record: inout Record, with inheritedRecord: Record) {
        let sortedKeys = record.keys.sorted()
        for key in sortedKeys {
            customMerge(&record, with: inheritedRecord, key: key)
        }
    }

    /// Merge the specified key from an inherited record.
    /// We try each custom combiner in turn until one says that it has succeeded.
    /// If none succeed, and the property already exists, we keep that value and ignore the inherited one.
    func customMerge(_ record: inout Record, with inheritedRecord: Record, key: String) {
        for combiner in customCombiners {
            if combiner(key, &record, inheritedRecord) {
                return
            }
        }
        
        if record[key] == nil {
            record[key] = inheritedRecord[key]
        }
    }

    mutating func loadRecords(fromFile url: URL, mode: LoadMode, idPrefix: String = "") throws {
        if let decoded = try JSONSerialization.jsonObject(from: url) as? [String:Any] {
            switch mode {
                case .oneRecordPerFile:
                    let name = url.deletingPathExtension().lastPathComponent
                    add([name: decoded])
                    
                case .multipleRecordsPerFile:
                    if let records = decoded as? DictionaryResolver.Index {
                        add(records)
                    }
            }
        }
    }
    
    mutating func loadRecords(fromFolder url: URL, mode: LoadMode, idPrefix: String = "") throws {
        let name = url.deletingPathExtension().lastPathComponent
        let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.nameKey], options: [.skipsSubdirectoryDescendants])
        for item in contents {
            try loadRecords(from: item, mode: mode, idPrefix: "\(idPrefix)\(name).")
        }
    }
}
