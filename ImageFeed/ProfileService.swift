//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Артем Кохан on 17.01.2023.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    
    private(set) var profile: Profile?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            if lastToken != token {
                task?.cancel()
            } else {
                return
            }
        } else {
            if lastToken == token {
                return
            }
        }
        lastToken = token
        
        let request = makeRequest(token: token)
        
        let session = URLSession.shared
        
        let task = session.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            
            switch result {
            case .success(let result):
                
                guard let self = self else {
                    completion(.failure(NetworkError.codeError))
                    return
                }
                let profile = Profile(profileResult: result)
                self.profile = profile
                
                DispatchQueue.main.async {
                    completion(.success(profile))
                }
            case .failure(let error):
                completion(.failure(error))
                self?.lastToken = ""
            }
            self?.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeRequest(token: String) -> URLRequest {
        
        guard  let url = URL(string: "https://api.unsplash.com/me") else { fatalError("Failed to create URL") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}

struct ProfileResult: Decodable {
    var username: String
    var firstName: String
    var lastName: String
    var bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case firstName  = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
}


struct Profile {
    let profileResult: ProfileResult
    var username: String {
        "@" + profileResult.username
    }
    var name: String {
        profileResult.firstName + " " + profileResult.lastName
    }
    var bio: String {
        guard let bio = profileResult.bio else { return ""}
        return bio
    }
}
