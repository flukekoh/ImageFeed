//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Артем Кохан on 26.12.2022.
//

import Foundation
final class OAuth2Service {
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        guard lastCode != code else { return }
        
        guard task == nil else {
            task?.cancel()
            return
        }
        
        lastCode = code
        
        let request = makeRequest(code: code)
        guard let request = request else { return }
        
        let session = URLSession.shared
        
        let task = session.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            
            switch result {
            case .success(let result):
                completion(.success(result.accessToken))
            case .failure(let error):
                self?.lastCode = nil
            }
            self?.task = nil

        }
        
        self.task = task
        task.resume()
        
    }
    
    private func makeRequest(code: String) -> URLRequest? {
        
        let unsplashAuthorizeTokenURLString = "https://unsplash.com/oauth/token"
        
        var urlComponents = URLComponents(string: unsplashAuthorizeTokenURLString)
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "client_secret", value: SecretKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents?.url else {
            assertionFailure("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return request
    }
}

