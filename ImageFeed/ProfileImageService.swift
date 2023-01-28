//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Артем Кохан on 23.01.2023.
//

import Foundation

final class ProfileImageService {
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    static let shared = ProfileImageService()
    
    private (set) var avatarURL: String?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastUsername: String?
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetchProfileImageURL(username: String, token: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        if task != nil {
            if lastUsername != username {
                task?.cancel()
            } else {
                return
            }
        } else {
            if lastUsername == username {
                return
            }
        }
        lastUsername = username
        
        let request = makeRequest(username: username, token: token)
        
        let session = URLSession.shared
        
        let task = session.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            
            switch result {
            case .success(let result):
                
                guard let self = self else {
                    completion(.failure(NetworkError.codeError))
                    return
                }
                self.avatarURL = result.profileImage.urlString
                
                let profileImageURL = URL(string: self.avatarURL!)
                DispatchQueue.main.async {
                    completion(.success(self.avatarURL!))
                    NotificationCenter.default                                     // 1
                        .post(                                                     // 2
                            name: ProfileImageService.DidChangeNotification,       // 3
                            object: self,                                          // 4
                            userInfo: ["URL": profileImageURL])
                    self.task = nil
                    
                }
            case .failure(let error):
                completion(.failure(error))
                self?.lastUsername = ""                     // 16
            }
            
            
        }
        
        
        self.task = task
        task.resume()
    }
    
    private func makeRequest(username: String, token: String) -> URLRequest {
        guard  let url = URL(string: "https://api.unsplash.com/users/\(username)") else { fatalError("Failed to create URL") }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
}

struct UserResult: Decodable {
    var profileImage: ProfileImages
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImages: Decodable {
    var urlString: String
    
    enum CodingKeys: String, CodingKey {
        case urlString = "small"
    }
}
