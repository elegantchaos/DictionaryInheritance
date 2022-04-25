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
        combiners.append(Combiners.combineCombinable)
        XCTAssertEqual(combiners.combine(["foo"], ["bar"]), ["bar", "foo"])
    }

    func testCombinedDictionaries() {
        var combiners = Combiners()
        combiners.append(Combiners.combineCombinable)
        XCTAssertEqual(combiners.combine(["foo" : "bar"], ["bar" : "foo"]), ["foo": "bar", "bar": "foo"])
    }

    func testCombinedDeepDictionaries() {
        var combiners = Combiners()
        combiners.append(Combiners.combineCombinable)
        let d1: [String:Any] = [
            "name": "d1",
            "d1": true,
            "sub": [
                "foo" : "bar"
            ],
            "list": ["foo"]
        ]
        
        let d2: [String:Any] = [
            "name": "d2",
            "d2": true,
            "sub" : [
                "bar" : "foo"
            ],
            "list": ["bar"]
        ]
        
        let combined = combiners.combine(d1, d2)
        
        XCTAssertEqual(combined["name"] as? String, "d1")
        XCTAssertTrue(combined["d1"] as! Bool)
        XCTAssertTrue(combined["d2"] as! Bool)
        XCTAssertEqual(combined["sub"] as? [String:String], [
            "foo": "bar",
            "bar": "foo"
        ])
        XCTAssertEqual(combined["list"] as? [String], ["bar", "foo"])
    }

}
