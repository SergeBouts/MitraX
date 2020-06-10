//
//  BankRaceTests.swift
//  MitraX
//
//  Created by Serge Bouts on 6/10/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import XCTest
import XConcurrencyKit
@testable
import MitraX

// Tests for SharedManager races with ArraySliceProperty.
final class BankRaceTests: XCTestCase {
    func test_nonOverlappingElementPairs() {
        // Given

        let bank = BankMock()

        func assertBankReportTotal() {
            let total = bank.report().reduce(0, +)
            XCTAssertEqual(total, BankMock.accountCount * BankMock.initialBalance)
        }

        let threadCollider = ThreadCollider()

        // When

        threadCollider.collide(victim: {
            // Race corral BEGIN

            if Int.random(in: 0..<100) <= 95 {
                let from = Int.random(in: 0..<bank.accounts.count)
                let to = (from + Int.random(in: 1..<bank.accounts.count)) % bank.accounts.count
                bank.transfer(from: from, to: to, amount: Int.random(in: -5...5))
            } else {
                assertBankReportTotal()
            }

            // Race corral END
        })

        // Then

        XCTAssertTrue(bank.raceDetector.noProblemDetected, "\(bank.raceDetector.exclusiveRaces + bank.raceDetector.nonExclusiveRaces) races out of \(bank.raceDetector.exclusivePasses + bank.raceDetector.nonExclusivePasses) passes")
        XCTAssertTrue(bank.raceDetector.nonExclusiveBenignRaces > 0)
        assertBankReportTotal()
        print(bank.accounts.map { $0.value })
    }
}
