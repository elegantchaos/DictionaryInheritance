// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 25/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import XCTestExtensions

@testable import DictionaryResolver

final class CombinerTests: XCTestCase {
    func testDefaultBehaviour() {
        let combiners = Combiners()
        XCTAssertEqual(combiners.combine(1, 2), 1)
    }
    
    func testDefaultLists() {
        let combiners = Combiners()
        XCTAssertEqual(combiners.combine(["foo"], ["bar"]), ["foo"])
    }

    func testCombinedLists() {
        var combiners = Combiners()
        combiners.append(Combiners.combineLists)
        XCTAssertEqual(combiners.combine(["foo"], ["bar"]), ["bar", "foo"])
    }

    func testCombinedDictionaries() {
        var combiners = Combiners()
        combiners.append(Combiners.combineLists)
        XCTAssertEqual(combiners.combine(["foo" : "bar"], ["bar" : "foo"]), ["foo": "bar", "bar": "foo"])
    }

}
