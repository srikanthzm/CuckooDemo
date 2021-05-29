//
//  User.swift
//  Demo
//
//  Created by Srikanth Thangavel on 28/05/21.
//

import Foundation

class User: Decodable {
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    init(name: String) {
        self.name = name
    }
}
