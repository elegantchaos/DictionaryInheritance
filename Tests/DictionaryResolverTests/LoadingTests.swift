// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import XCTestExtensions

@testable import DictionaryResolver

final class LoadingTests: XCTestCase {
    func testFolder(named name: String, mode: DictionaryResolver.LoadMode) throws -> DictionaryResolver {
        let url = Bundle.module.url(forResource: name, withExtension: nil)!
        var resolver = DictionaryResolver()
        try resolver.loadRecords(from: url, mode: mode)
        resolver.resolve()
        
        return resolver
    }

    func testNestedIDs() throws {
        let resolver = try testFolder(named: "Structured", mode: .singleRecordPerFileSkipRootID)
        let ids = Set(resolver.resolved.keys)
        XCTAssertTrue(ids.contains("Object1"))
        XCTAssertTrue(ids.contains("Object2"))
        XCTAssertTrue(ids.contains("Section1.Object3"))
        XCTAssertTrue(ids.contains("Section1.Object4"))
        XCTAssertTrue(ids.contains("Section2.Object5"))
        XCTAssertTrue(ids.contains("Section2.Object6"))
    }

    func testNestedIDsWithRoot() throws {
        let resolver = try testFolder(named: "Structured", mode: .singleRecordPerFileWithNestedID)
        let ids = Set(resolver.resolved.keys)
        XCTAssertTrue(ids.contains("Structured.Object1"))
        XCTAssertTrue(ids.contains("Structured.Object2"))
        XCTAssertTrue(ids.contains("Structured.Section1.Object3"))
        XCTAssertTrue(ids.contains("Structured.Section1.Object4"))
        XCTAssertTrue(ids.contains("Structured.Section2.Object5"))
        XCTAssertTrue(ids.contains("Structured.Section2.Object6"))
    }

    func testFlatIDs() throws {
        let resolver = try testFolder(named: "Structured", mode: .singleRecordPerFileNoNestedID)
        let ids = Set(resolver.resolved.keys)
        XCTAssertTrue(ids.contains("Object1"))
        XCTAssertTrue(ids.contains("Object2"))
        XCTAssertTrue(ids.contains("Object3"))
        XCTAssertTrue(ids.contains("Object4"))
        XCTAssertTrue(ids.contains("Object5"))
        XCTAssertTrue(ids.contains("Object6"))
    }

}
