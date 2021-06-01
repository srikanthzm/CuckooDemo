//
//  MockNetwork.swift
//  DemoUITests
//
//  Created by Srikanth Thangavel on 31/05/21.
//

import Foundation

final class MockURLProtocol: URLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return false
    }
    
    override func startLoading() {
        guard
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [:])        else {
            client?.urlProtocol(self, didFailWithError: MockError.missingMockedData(url: String(describing: request.url?.absoluteString)))
            return
        }
        
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        self.client?.urlProtocol(self, didLoad: MockData.exampleJSON.data)
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override public func stopLoading() {    }
    
}

enum MockError: Swift.Error, LocalizedError, CustomDebugStringConvertible {
    case missingMockedData(url: String)
    case explicitMockFailure(url: String)

    var errorDescription: String? {
        return debugDescription
    }

    var debugDescription: String {
        switch self {
        case .missingMockedData(let url):
            return "Missing mock for URL: \(url)"
        case .explicitMockFailure(url: let url):
            return "Induced error for URL: \(url)"
        }
    }
}
