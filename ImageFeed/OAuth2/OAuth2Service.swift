//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Артем Кохан on 26.12.2022.
//

import Foundation
class OAuth2Service {
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let UnsplashAuthorizeTokenURLString = "https://unsplash.com/oauth/token"
        
        var urlComponents = URLComponents(string: UnsplashAuthorizeTokenURLString)
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "client_secret", value: secretKey),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
            ]
     
        guard let url = urlComponents?.url else { return completion(.failure(NetworkError.codeError)) }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
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
                    let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(response.access_token))
                    }
                } catch let error {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}

