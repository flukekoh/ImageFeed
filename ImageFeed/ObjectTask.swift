//
//  ObjectTask.swift
//  ImageFeed
//
//  Created by Артем Кохан on 24.01.2023.
//

import Foundation

extension URLSession {
    private enum NetworkError: Error {
        case codeError
        case wrongData
    }
    
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        
        let task = dataTask(with: request){ data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.codeError))
                }
                return
            }
            
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.wrongData))
                }
            }
        }
        
        return task
    }
}
