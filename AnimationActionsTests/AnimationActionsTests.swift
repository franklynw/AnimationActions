//
//  AnimationActionsTests.swift
//  AnimationActionsTests
//
//  Created by Franklyn on 08/06/2020.
//  Copyright © 2020 Franklyn. All rights reserved.
//

import XCTest
@testable import AnimationActions

import UIKit

class AnimationActionsTests: XCTestCase {

    var animation: CABasicAnimation {

        let animation = CABasicAnimation(keyPath: "opacity")

        animation.fromValue = NSNumber(value: 0)
        animation.toValue = NSNumber(value: 1)
        animation.duration = 1

        return animation
    }

    func testBeganAndFinishedActions() {

        let animation = self.animation
        let layer = CALayer()

        var began = false
        var finished = false

        let beganExpectation = expectation(description: "animationBegan")
        let finishedExpectation = expectation(description: "animationFinished")

        animation.began = {
            began = true
            beganExpectation.fulfill()
        }
        animation.finished = { _, _ in
            finished = true
            finishedExpectation.fulfill()
        }

        layer.add(animation, forKey: nil)

        wait(for: [beganExpectation], timeout: 1)

        XCTAssertTrue(began, "Should be true")

        wait(for: [finishedExpectation], timeout: 5)

        XCTAssertTrue(finished, "Should be true")
    }

    func testBeganAndFinishedActionsOverrideDelegate() {

        let animation = self.animation
        let layer = CALayer()

        var began = false
        var finished = false

        let beganExpectation = expectation(description: "animationBegan")
        let finishedExpectation = expectation(description: "animationFinished")

        animation.delegate = self

        animation.began = {
            began = true
            beganExpectation.fulfill()
        }
        animation.finished = { _, _ in
            finished = true
            finishedExpectation.fulfill()
        }

        layer.add(animation, forKey: nil)

        wait(for: [beganExpectation], timeout: 1)

        XCTAssertTrue(began, "Should be true")

        wait(for: [finishedExpectation], timeout: 5)

        XCTAssertTrue(finished, "Should be true")
    }

    func testBeganAndFinishedActionsNotCalledIfDelegateSet() {

        let animation = self.animation
        let layer = CALayer()

        var began = false
        var finished = false

        let beganExpectation = expectation(description: "animationBegan")
        let finishedExpectation = expectation(description: "animationFinished")

        animation.began = {
            began = true
            beganExpectation.fulfill()
        }
        animation.finished = { _, _ in
            finished = true
            finishedExpectation.fulfill()
        }

        animation.delegate = self

        layer.add(animation, forKey: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            beganExpectation.fulfill()
            finishedExpectation.fulfill()
        }

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "Timed out")
        }

        XCTAssertFalse(began, "Should be false")
        XCTAssertFalse(finished, "Should be false")
    }
}

extension AnimationActionsTests: CAAnimationDelegate {

    func animationDidStart(_ anim: CAAnimation) {
        print("Animation began")
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print("Animation ended")
    }
}
