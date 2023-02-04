//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Артем Кохан on 23.01.2023.
//

import Foundation

final class ProfileImageService {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    static let shared = ProfileImageService()
    
    private (set) var avatarURL: String?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastUsername: String?
    private enum NetworkError: Error {
        case codeError
    }
    
    private init() {
        
    }
    
    func fetchProfileImageURL(username: String, token: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        guard lastUsername != username else { return }
        
        guard task == nil else {
            task?.cancel()
            return
        }
        
        let request = makeRequest(username: username, token: token)
        
        let session = URLSession.shared
        var profileImageURL: URL?
        
        let task = session.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            
            switch result {
            case .success(let result):
                guard let self = self else {
                    completion(.failure(NetworkError.codeError))
                    return
                }
                self.avatarURL = result.profileImage.urlString
                profileImageURL = URL(string: self.avatarURL!)
            case .failure(let error):
                completion(.failure(error))
                self?.lastUsername = ""
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImageURL])
                guard let self = self else {
                    return
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeRequest(username: String, token: String) -> URLRequest {
        guard  let url = URL(string: "https://api.unsplash.com/photos/\(username)") else { fatalError("Failed to create URL") }
        
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
