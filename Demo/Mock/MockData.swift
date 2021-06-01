//
//  MockData.swift
//  Demo
//
//  Created by Srikanth Thangavel on 01/06/21.
//

import Foundation

/// Contains all available Mocked data.
public final class MockData {


    public static let exampleJSON: URL = Bundle(for: MockData.self).url(forResource: "Resource/user", withExtension: "json")!
}

internal extension URL {
    /// Returns a `Data` representation of the current `URL`. Force unwrapping as it's only used for tests.
    var data: Data {
        return try! Data(contentsOf: self)
    }
}
