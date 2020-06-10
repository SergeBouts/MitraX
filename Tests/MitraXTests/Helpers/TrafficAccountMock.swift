//
//  TrafficAccountMock.swift
//  MitraX
//
//  Created by Serge Bouts on 6/10/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import MitraX
import XConcurrencyKit

// Mock of the traffic consumer account
struct TrafficAccountMock {
    let sharedManager: SharedManager
    let raceDetector = RaceSensitiveSection()

    // MARK: - State

    private let balance: Property<Double> // remaining money
    private let traffic: Property<Double> // traffic consumed

    // MARK: - Initialization

    init() {
        sharedManager = SharedManager()
        balance = Property<Double>(value: 0, sharedManager: sharedManager)
        traffic = Property<Double>(value: 0, sharedManager: sharedManager)
    }

    // MARK: - Queries

    var currentBalance: Double {
        sharedManager.borrow(balance.ro) { balance in
            raceDetector.nonExclusiveCriticalSection({
                return balance.value
            }, register: { $0(0) })
        }
    }

    var currentTraffic: Double {
        sharedManager.borrow(traffic.ro) { traffic in
            raceDetector.nonExclusiveCriticalSection({
                return traffic.value
            }, register: { $0(1) })
        }
    }

    func summary() -> (balance: Double, traffic: Double) {
        sharedManager.borrow(balance.ro, traffic.ro) { balance, traffic in
            raceDetector.nonExclusiveCriticalSection({
                return (balance: balance.value, traffic: traffic.value)
            }, register: { register in [0, 1].forEach { register($0) } })
        }
    }

    // MARK: - Commands

    func topUp(for amount: Double) {
        sharedManager.borrow(balance.rw) { balance in
            raceDetector.exclusiveCriticalSection({
                balance.value += amount
            }, register: { $0(0) })
        }
    }

    func consume(_ gb: Double, at costPerGb: Double) -> Double {
        sharedManager.borrow(balance.rw, traffic.rw) { balance, traffic in
            raceDetector.exclusiveCriticalSection({
                let cost = gb * costPerGb
                let spent = balance.value < cost ? balance.value : cost
                balance.value -= spent
                let consumed = spent / costPerGb
                traffic.value += consumed
                return consumed
            }, register: { register in [0, 1].forEach { register($0) } })
        }
    }
}
