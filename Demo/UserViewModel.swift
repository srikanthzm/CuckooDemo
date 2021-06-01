//
//  UserViewModel.swift
//  Demo
//
//  Created by Srikanth Thangavel on 28/05/21.
//

import Foundation
import Alamofire

class UserViewModel {
    
    private let manager: Session
    
    init(manager: Session = Environment.shared.session) {
        self.manager = manager
    }
    
    func getData(completion: @escaping((User) -> Void)) {
        manager.request("http://swapi.dev/api/starships/2/").responseDecodable(of: User.self) { (response) in
            guard let value = response.value else { return }
            completion(value)
        }
    }
    
}
