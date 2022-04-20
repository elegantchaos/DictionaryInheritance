// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/04/2022.
//  All code (c) 2022 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import XCTestExtensions

@testable import DictionaryResolver

final class DictionaryResolverTests: XCTestCase {
    func testResolver(named name: String, resolve: Bool = true) throws -> DictionaryResolver {
        let url = testURL(named: name, withExtension: "json")
        var resolver = DictionaryResolver()
        try resolver.loadRecords(from: url, mode: .multipleRecordsPerFile)
        if resolve {
            resolver.resolve()
        }
        
        return resolver
    }
    
    func testSingleInheritance() throws {
        let index = try testResolver(named: "SimpleTest")

        let r2 = index.record(withID: "r2")!
        XCTAssertEqual(r2["foo"] as? String, "bar")
        XCTAssertEqual(r2["bar"] as? String, "foo")
    }

    func testThreeLevelInheritance() throws {
        let index = try testResolver(named: "ThreeLevelTest")

        let r3 = index.record(withID: "r3")!
        XCTAssertEqual(r3["foo"] as? String, "bar")
        XCTAssertEqual(r3["bar"] as? String, "foo")
        XCTAssertEqual(r3["wibble"] as? String, "wobble")
    }

    func testMultipleInheritance() throws {
        let index = try testResolver(named: "MultipleTest")

        let r3 = index.record(withID: "r3")!
        XCTAssertEqual(r3["foo"] as? String, "bar")
        XCTAssertEqual(r3["bar"] as? String, "foo")
        XCTAssertEqual(r3["wibble"] as? String, "wobble")
    }

    func testLoop() throws {
        let index = try testResolver(named: "LoopTest")

        let r1 = index.record(withID: "r1")!
        XCTAssertEqual(r1["foo"] as? String, "bar")
        XCTAssertEqual(r1["bar"] as? String, "foo")
    }

    func testInheritorOverwritesInherited() throws {
        let index = try testResolver(named: "OverwriteTest")
        
        let r2 = index.record(withID: "r2")!
        XCTAssertEqual(r2["foo"] as? String, "bar")
    }

    func testMergingListsByKey() throws {
        var index = try testResolver(named: "ListMergeTest", resolve: false)
        index.addCombinerForKeys(["merged"], DictionaryResolver.combineStringLists)
        index.resolve()
        
        let r2 = index.record(withID: "r2")!
        XCTAssertEqual(r2["merged"] as? [String], ["foo", "bar"])
        XCTAssertEqual(r2["unmerged"] as? [String], ["bar"])
    }

    func testMergingListsByType() throws {
        var index = try testResolver(named: "ListMergeTest", resolve: false)
        index.addCombiner(DictionaryResolver.combineStringLists)
        index.resolve()
        
        let r2 = index.record(withID: "r2")!
        XCTAssertEqual(r2["merged"] as? [String], ["foo", "bar"])
        XCTAssertEqual(r2["unmerged"] as? [String], ["foo", "bar"])
    }

    func testLoadingFolderSingleRecord() throws {
        let url = testURL(named: "SimpleTest", withExtension: "json")
        let folder = url.deletingLastPathComponent()
        var resolver = DictionaryResolver()
        try resolver.loadRecords(from: folder, mode: .oneRecordPerFile)
        XCTAssertEqual(resolver.records.count, 6)
    }

    func testLoadingFolderMultipleRecords() throws {
        let url = testURL(named: "SimpleTest", withExtension: "json")
        let folder = url.deletingLastPathComponent()
        var resolver = DictionaryResolver()
        try resolver.loadRecords(from: folder, mode: .multipleRecordsPerFile)
        // multiple versions of "r1", "r2" and "r3" will overwrite each other, so the count will end up just being 3
        XCTAssertEqual(resolver.records.count, 3)
    }

}
