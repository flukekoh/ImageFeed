//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Артем Кохан on 04.02.2023.
//

import Foundation

final class ImageListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    static let shared = ImageListService()
    
    private let perPage: Int = 10
    private let orderBy: String = "popular"
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if task != nil {
            return
        }
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        
        
        let request = makeRequest(page: nextPage)
        
        let session = URLSession.shared
        var profileImageURL: URL?
        
        let task = session.objectTask(for: request) { [weak self] (result: Result<PhotoResult, Error>) in
            
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
                        name: ImageListService.didChangeNotification,
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
    
    private func makeRequest(page: Int) -> URLRequest {
        guard  let url = URL(string: "https://api.unsplash.com/photos/") else { fatalError("Failed to create URL") }
        
        var request = URLRequest(url: url)
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
}

struct PhotoResult {
    let id: String
    let width: Int
    let height: Int
    let createdAt: Date?
    let welcomeDescription: String?
    
    let urls: URLsResult
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case width = "width"
        case height = "height"
        case createdAt = "created_at"
        case welcomeDescription = "description"
        case urls = "urls"
    }
}

struct URLsResult {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
