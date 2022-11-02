//
//  BasicTests.swift
//  MitraX
//
//  Created by Serhiy Butz on 6/10/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import XCTest
@testable
import MitraX

final class BasicTests: XCTestCase {
    let sut = SharedManager()

    func test_int() {
        // Given

        let foo = Property(value: 0, sharedManager: sut)

        // When

        sut.borrow(foo.rw) { foo in
            XCTAssertEqual(foo.value, 0)
            foo.value = 1
        }

        // Then

        sut.borrow(foo.ro) { foo in
            XCTAssertEqual(foo.value, 1)
        }
    }

    func test_string() {
        // Given

        let foo = Property(value: "", sharedManager: sut)

        // When

        sut.borrow(foo.rw) { foo in
            XCTAssertEqual(foo.value, "")
            foo.value = "foo"
        }

        // Then

        sut.borrow(foo.ro) { foo in
            XCTAssertEqual(foo.value, "foo")
        }
    }

    func test_optional() {
        // Given

        let foo = Property<Int?>(value: nil, sharedManager: sut)

        // When

        sut.borrow(foo.rw) { foo in
            XCTAssertNil(foo.value)
            foo.value = 1
        }

        // Then

        sut.borrow(foo.ro) { foo in
            XCTAssertEqual(foo.value, 1)
        }
    }

    func test_array() {
        // Given

        let foo = Property<Array<Int>>(value: [], sharedManager: sut)

        // When

        sut.borrow(foo.rw) { foo in
            XCTAssertEqual(foo.value, [])
            foo.value = [1, 2]
            foo.value.append(3)
        }

        // Then

        sut.borrow(foo.ro) { foo in
            XCTAssertEqual(foo.value, [1, 2, 3])
        }
    }

    func test_dictionary() {
        // Given

        let foo = Property<Dictionary<String, Int>>(value: [:], sharedManager: sut)

        // When

        sut.borrow(foo.rw) { foo in
            XCTAssertEqual(foo.value, [:])
            foo.value = ["foo": 2]
            foo.value["bar"] = 3
        }

        // Then

        sut.borrow(foo.ro) { foo in
            XCTAssertEqual(foo.value, ["foo": 2, "bar": 3])
        }
    }

    func test_set() {
        // Given

        let foo = Property<Set<String>>(value: [], sharedManager: sut)

        // When

        sut.borrow(foo.rw) { foo in
            XCTAssertEqual(foo.value, [])
            foo.value = ["foo"]
            foo.value.insert("bar")
        }

        // Then

        sut.borrow(foo.ro) { foo in
            XCTAssertEqual(foo.value, ["foo", "bar"])
        }
    }

    func test_nested() {
        // Given

        let foo = Property(value: 0, sharedManager: sut)

        // When

        sut.borrow(foo.ro) {
            XCTAssertEqual($0.value, 0)

            // When

            sut.borrow(foo.rw) {
                $0.value = 1
            }

            // Then

            XCTAssertEqual($0.value, 1)
        }
    }
}
