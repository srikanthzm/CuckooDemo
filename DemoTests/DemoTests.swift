//
//  DemoTests.swift
//  DemoTests
//
//  Created by Srikanth Thangavel on 28/05/21.
//

import XCTest
@testable import Demo

class DemoTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
//    func testUserViewModel() throws {
//        let mockUser = MockUser(name: "Mock Name")
//        let mock = MockUrlSession()
//        let urlStr  = "https://riis.com"
//        let url  = URL(string:urlStr)!
//        
//        // Arrange
//        stub(mock) { (mock) in
//            when(mock.url).get.thenReturn(url)
//        }
//        
//        stub(mock) { (mock) in
//            when(mock.session).get.thenReturn(URLSession(configuration: .default))
//        }
//        
//        stub(mock) { (mock) in
//            when(mock.getUser(completion: anyClosure())).then { (result) in
//                result(.success(mockUser))
//            }
//        }
//        
//        // Act and Assert
//        XCTAssertEqual(mock.url, url)
//        XCTAssertEqual(mock.url?.absoluteString, urlStr)
//        XCTAssertNotNil(mock.session)
//        mock.getUser { (result) in
//            switch result {
//            case .success(let user):
//                XCTAssertEqual(user.name, mockUser.name)
//            case .failure(let error):
//                XCTAssertNil(error)
//            }
//        }
//        XCTAssertNotNil(verify(mock).session)
//        XCTAssertNotNil(verify(mock).url)
//    }
    
}
