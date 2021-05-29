//
//  UserViewModel.swift
//  Demo
//
//  Created by Srikanth Thangavel on 28/05/21.
//

import Foundation
import Alamofire

class UserViewModel {
    
    init() {}
    
//    func getData(completion: @escaping((User) -> Void)) {
//        AF.request("http://swapi.dev/api/starships/2/").responseDecodable(of: User.self) { (response) in
//            guard let value = response.value else { return }
//            completion(value)
//        }
//    }
    
    func getData(completion: @escaping((User?) -> Void)) {
        let sesssion = UrlSession()
        sesssion.getUser(completion: { (result) in
            switch result {
            case .success(let user):
                completion(user)
            case .failure(_):
                completion(nil)
            }
        })
    }
    
}
