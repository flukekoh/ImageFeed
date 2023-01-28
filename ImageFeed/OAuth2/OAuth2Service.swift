//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Артем Кохан on 26.12.2022.
//

import Foundation
class OAuth2Service {
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)                         // 4
        if task != nil {                                    // 5
            if lastCode != code {                           // 6
                task?.cancel()                              // 7
            } else {
                return                                      // 8
            }
        } else {
            if lastCode == code {                           // 9
                return
            }
        }
        lastCode = code                                     // 10
        let request = makeRequest(code: code)               // 11
        
        let session = URLSession.shared
        
        let task = session.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            
            switch result {
            case .success(let result):
                DispatchQueue.main.async {
                    completion(.success(result.access_token))
                    self?.task = nil                             // 14
                    
                }
            case .failure(let error):
                    self?.lastCode = nil                     // 16
            }
            
            
        }
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            if let response = response as? HTTPURLResponse,
//               response.statusCode < 200 || response.statusCode >= 300 {
//                completion(.failure(NetworkError.codeError))
//                return
//            }
//
//            if let data = data {
//                do {
//                    print(data)
//                    let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
//                    DispatchQueue.main.async {
//                        completion(.success(response.access_token))
//                        self.task = nil                             // 14
//                        if error != nil {                           // 15
//                            self.lastCode = nil                     // 16
//                        }
//                    }
//                } catch let error {
//                    completion(.failure(error))
//                }
//            }
//        }
        self.task = task
        task.resume()
        
    }
    
    private func makeRequest(code: String) -> URLRequest {
        
        let UnsplashAuthorizeTokenURLString = "https://unsplash.com/oauth/token"
        
        var urlComponents = URLComponents(string: UnsplashAuthorizeTokenURLString)
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "client_secret", value: secretKey),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents?.url else { fatalError("Failed to create URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return request
    }
}

