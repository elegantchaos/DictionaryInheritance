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

    let inheritanceKey: String
    let resolvingKey: String
    private static let resolvingSentinel = ResolvingSentinel()
    
    /// Unprocessed records.
    var records: Index
    
    /// Source mapping for records.
    var sources: [String:URL]

    /// Resolved records.
    var resolved: Index
    
    /// Custom combining functions, stored by key.
    var combiners: Combiner

    /// Create with an existing set of records.
    public init(_ records: Index = [:], sources: [String:URL] = [:], inheritanceKey: String = "inherits", resolvingKey: String = "«resolving»") {
        self.records = records
        self.resolved = [:]
        self.sources = sources
        self.combiners = Combiner()
        self.inheritanceKey = inheritanceKey
        self.resolvingKey = resolvingKey
    }
    
    /// Add a record to the index.
    public mutating func add(_ record: Record, withID id: String, source: URL? = nil) {
        records[id] = record
        sources[id] = source
    }
    
    /// Add some records to the index.
    public mutating func add(_ newRecords: Index, source: URL? = nil) {
        records.mergeReplacingDuplicates(newRecords)
        if let source = source {
            for id in newRecords.keys {
                sources[id] = source
            }
        }
    }
    
    /// Register a custom function to combine values.
    public mutating func addCombiner(_ combiner: @escaping Combiner.Processor) {
        combiners.append(combiner)
    }

    public enum LoadMode {
        case singleRecordPerFileSkipRootID          // Skip the root folder name when calculating the record id.
        case singleRecordPerFileWithNestedID        // Append the folder name to the record id.
        case singleRecordPerFileNoNestedID          // Never the folder name to the record id.
        case multipleRecordsPerFile                 // Each file contains a dictionary with multiple records. The first level of keys are the record ids.
    }
    
    /// Add some records to the index from a file.
    public mutating func loadRecords(from url: URL, mode: LoadMode = .singleRecordPerFileSkipRootID, idPrefix: String = "") throws {
        if url.hasDirectoryPath {
            try loadRecords(fromFolder: url, mode: mode, idPrefix: idPrefix)
        } else {
            try loadRecords(fromFile: url, mode: mode, idPrefix: idPrefix)
        }
    }
    

    /// Resolve all unresolved records.
    public mutating func resolve() {
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
                merged.merge(inheritedValues, uniquingKeysWith: { existing, new in
                    combiners.combine(existing, new)
                })
            } else {
                print("missing record \(inheritedKey)")
            }
        }
        
        resolved[key] = merged
        return merged
    }

    mutating func loadRecords(fromFile url: URL, mode: LoadMode, idPrefix: String = "") throws {
        if let decoded = try JSONSerialization.jsonObject(from: url) as? [String:Any] {
            switch mode {
                case .singleRecordPerFileSkipRootID, .singleRecordPerFileNoNestedID:
                    let id = url.deletingPathExtension().lastPathComponent
                    add(decoded, withID: id, source: url)

                case .singleRecordPerFileWithNestedID:
                    let name = url.deletingPathExtension().lastPathComponent
                    let id = "\(idPrefix)\(name)"
                    add(decoded, withID: id, source: url)

                case .multipleRecordsPerFile:
                    if let records = decoded as? DictionaryResolver.Index {
                        add(records, source: url)
                    }
            }
        }
    }
    
    mutating func loadRecords(fromFolder url: URL, mode: LoadMode, idPrefix: String = "") throws {
        let name = url.deletingPathExtension().lastPathComponent
        let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.nameKey], options: [.skipsSubdirectoryDescendants])
        
        let recursiveMode: LoadMode
        let recursivePrefix: String
        
        switch mode {
            case .singleRecordPerFileSkipRootID:
                recursivePrefix = idPrefix
                recursiveMode = .singleRecordPerFileWithNestedID

            case .singleRecordPerFileNoNestedID:
                recursivePrefix = idPrefix
                recursiveMode = mode

            default:
                recursivePrefix = "\(idPrefix)\(name)."
                recursiveMode = mode
        }
        
        for item in contents {
            try loadRecords(from: item, mode: recursiveMode, idPrefix: recursivePrefix)
        }
    }
}
