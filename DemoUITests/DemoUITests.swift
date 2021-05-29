//
//  DemoUITests.swift
//  DemoUITests
//
//  Created by Srikanth Thangavel on 28/05/21.
//

@testable import Demo
import XCTest
import Cuckoo

class DemoUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        app = XCUIApplication()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        app = nil
    }

    func testExample() throws {
        app.launch()
        
        let mockUser = MockUser(name: "Mock Name")
        let mock = MockUrlSession()
        let urlStr  = "https://riis.com"
        let url  = URL(string:urlStr)!
        
        // Arrange
        stub(mock) { (mock) in
            when(mock.url).get.thenReturn(url)
        }
                
        stub(mock) { (mock) in
            when(mock.getUser(completion: anyClosure())).then { (result) in
                result(.success(mockUser))
            }
        }
        
        // Act and Assert
        wait(for: 2)
        XCTAssertEqual(app.staticTexts["name-label"].label, mockUser.name)
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
