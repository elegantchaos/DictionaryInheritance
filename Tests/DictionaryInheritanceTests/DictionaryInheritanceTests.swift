// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/04/2022.
//  All code (c) 2022 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import XCTestExtensions

@testable import DictionaryInheritance

final class DictionaryInheritanceTests: XCTestCase {
    func testSingleInheritance() throws {
        let example = try testDictionary(named: "SimpleTest")
        
        var index = DictionaryIndex(example as! DictionaryIndex.Index)
        index.resolve()
        
        let r2 = index.record(withID: "r2")!
        XCTAssertEqual(r2["foo"] as? String, "bar")
        XCTAssertEqual(r2["bar"] as? String, "foo")
    }

    func testThreeLevelInheritance() throws {
        let example = try testDictionary(named: "ThreeLevelTest")
        
        var index = DictionaryIndex(example as! DictionaryIndex.Index)
        index.resolve()
        
        let r3 = index.record(withID: "r3")!
        XCTAssertEqual(r3["foo"] as? String, "bar")
        XCTAssertEqual(r3["bar"] as? String, "foo")
        XCTAssertEqual(r3["wibble"] as? String, "wobble")
    }

    func testMultipleInheritance() throws {
        let example = try testDictionary(named: "MultipleTest")
        
        var index = DictionaryIndex(example as! DictionaryIndex.Index)
        index.resolve()
        
        let r3 = index.record(withID: "r3")!
        XCTAssertEqual(r3["foo"] as? String, "bar")
        XCTAssertEqual(r3["bar"] as? String, "foo")
        XCTAssertEqual(r3["wibble"] as? String, "wobble")
    }

    func testLoop() throws {
        let example = try testDictionary(named: "LoopTest")
        
        var index = DictionaryIndex(example as! DictionaryIndex.Index)
        index.resolve()
        
        let r2 = index.record(withID: "r2")!
        XCTAssertEqual(r2["foo"] as? String, "bar")
        XCTAssertEqual(r2["bar"] as? String, "foo")
    }

}

extension XCTestCase {
    func testDictionary(named name: String) throws -> [String:Any] {
        let url = testURL(named: name, withExtension: "json")
        let data = try Data(contentsOf: url)
        return try JSONSerialization.jsonObject(with: data) as! [String:Any]
    }
}
