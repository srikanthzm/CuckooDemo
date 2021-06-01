//
//  DemoUITests.swift
//  DemoUITests
//
//  Created by Srikanth Thangavel on 28/05/21.
//

import XCTest

class DemoUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        app = XCUIApplication()
        app.launchEnvironment = ["AppEnvironment": "UI-Testing"]
        continueAfterFailure = false
    }
    
    override func tearDown() {
        app = nil
    }

    func testExample() throws {
        app.launch()
        
        // Act and Assert
        XCTAssertEqual(app.staticTexts["name-label"].label, "Srikanth")
    }

}

//MARK: Delay function

extension XCTestCase {
    
    func wait(for duration: TimeInterval) {
        let waitExpectation = expectation(description: "Waiting")
        
        let when = DispatchTime.now() + duration
        DispatchQueue.main.asyncAfter(deadline: when) {
            waitExpectation.fulfill()
        }
        
        waitForExpectations(timeout: duration + 0.5)
    }
    
}
