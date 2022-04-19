// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/04/2022.
//  All code (c) 2022 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import XCTestExtensions

@testable import DictionaryResolver

final class DictionaryResolverTests: XCTestCase {
    func testResolver(named name: String) throws -> DictionaryResolver {
        let url = testURL(named: name, withExtension: "json")
        var resolver = DictionaryResolver()
        try resolver.loadRecords(from: url)
        resolver.resolve()
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
        let index = try testResolver(named: "MutlipleTest")

        let r3 = index.record(withID: "r3")!
        XCTAssertEqual(r3["foo"] as? String, "bar")
        XCTAssertEqual(r3["bar"] as? String, "foo")
        XCTAssertEqual(r3["wibble"] as? String, "wobble")
    }

    func testLoop() throws {
        let index = try testResolver(named: "LoopTest")

        let r2 = index.record(withID: "r2")!
        XCTAssertEqual(r2["foo"] as? String, "bar")
        XCTAssertEqual(r2["bar"] as? String, "foo")
    }

    func testInheritorOverwritesInherited() throws {
        let index = try testResolver(named: "OverwriteTest")
        
        let r2 = index.record(withID: "r2")!
        XCTAssertEqual(r2["foo"] as? String, "bar")
    }
}

extension XCTestCase {
}
