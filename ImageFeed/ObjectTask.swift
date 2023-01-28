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
    }
    
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        
        let task = dataTask(with: request){ data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                completion(.failure(NetworkError.codeError))
                return
            }
            
            if let data = data {
                do {
                    print(data)
                    let response = try JSONDecoder().decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
                } catch let error {
                    completion(.failure(error))
                }
            }
        }
        
        return task
    }
}
