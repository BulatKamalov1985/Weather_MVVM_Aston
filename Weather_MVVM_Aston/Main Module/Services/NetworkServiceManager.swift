//
//  NetworkServiceManager.swift
//  Weather_MVVM_Aston
//
//  Created by Bulat Kamalov on 20.08.2023.
//

import Foundation

class NetworkServiceManager {
    static let shared = NetworkServiceManager()
    
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration)
    }
    
    func fetchData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = session.dataTask(with: url) { data, response, error in
            completion(data, response, error)
        }
        task.resume()
    }
}

