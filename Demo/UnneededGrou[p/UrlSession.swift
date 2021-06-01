//
//  UrlSession.swift
//  Demo
//
//  Created by Srikanth Thangavel on 28/05/21.
//

import Foundation

let starshipUrl = "http://swapi.dev/api/starships/2/"

class UrlSession {
    var url:URL!
    var session:URLSession!
    
    init() {
        url = URL(string: starshipUrl)
        session = URLSession(configuration: .default)
    }
    
    func getUser(completion: @escaping (Result<User, Error>) -> Void) {
        session.dataTask(with: url as URL) { (data, _, error) -> Void in
            if let data = data, let object = try? JSONDecoder().decode(User.self, from: data) {
                completion(.success(object))
            } else {
                completion(.failure(error ?? NetworkError()))
            }
        }.resume()
    }
}

struct NetworkError: Error {}
