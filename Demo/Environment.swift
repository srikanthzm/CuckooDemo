//
//  AppEnvironment.swift
//  Demo
//
//  Created by Srikanth Thangavel on 31/05/21.
//

import Foundation
import Alamofire

enum AppEnvironment {
    case uitesting
    
    var value: String {
        switch self {
        case .uitesting:
            return "UI-Testing"
        }
    }
    
    static func getKey() -> String {
        return String(describing: self)
    }
}

class Environment {
    
    static let shared = Environment()
    
    private init() {}
    
    var isAppEnvironmentUITesting: Bool {
//        return true
        return ProcessInfo.processInfo.environment[AppEnvironment.getKey()] == AppEnvironment.uitesting.value
    }
    
    var session: Session {
        if isAppEnvironmentUITesting {
            let configuration = URLSessionConfiguration.default
            configuration.protocolClasses = [MockURLProtocol.self] + (configuration.protocolClasses ?? [])

            return Session(configuration: configuration)
        } else {
            return AF
        }
    }
    
}
