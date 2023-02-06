//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Артем Кохан on 04.02.2023.
//

import Foundation

final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int = 0
    private var task: URLSessionTask?
    static let shared = ImagesListService()
    
    private let perPage: Int = 10
    private let orderBy: String = "popular"
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private enum NetworkError: Error {
        case codeError
        case photoError
    }
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if task != nil {
            return
        }
        let nextPage = lastLoadedPage == 0 ? 1 : lastLoadedPage + 1
        
        let request = makeRequest(page: nextPage)
        
        let session = URLSession.shared
        
        let task = session.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let photos):
                
                self.lastLoadedPage += 1
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.photos.append(contentsOf: photos.map {item in self.getPhotoResult(photo: item)})
                    
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["Photos": self.photos]
                    )
                }
                
                self.task = nil
                self.lastLoadedPage = nextPage
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        self.task = task
        task.resume()
    }
    
    private func getPhotoResult(photo: PhotoResult) -> Photo {
        Photo(id: photo.id, size: CGSize(width: photo.width, height: photo.height), createdAt: dateFormatter.date(from: photo.createdAt) ?? Date(), welcomeDescription: photo.welcomeDescription, thumbImageURL: URL(string: photo.urls.thumb) , largeImageURL: URL(string: photo.urls.full), isLiked: photo.isLiked)
    }
    
    private func makeRequest(page: Int) -> URLRequest {

        guard let token = OAuth2TokenStorage().token else { fatalError("No token provided") }
                
        guard var urlComponents = URLComponents(url: defaultBaseURL, resolvingAgainstBaseURL: false) else { fatalError() }
        urlComponents.path = "/photos"
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "order_by", value: "\(orderBy)")
        ]
        let url = urlComponents.url!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        if task != nil {
            return
        }
        
        let request = makeRequest(for: photoId, isLike: isLike)
        
        let session = URLSession.shared
        
        let task = session.objectTask(for: request) { [weak self] (result: Result<LikeResult, Error>) in
            
            switch result {
            case .success:
                
                guard let self = self else { return }
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos[index] = newPhoto
                    completion(.success(()))
                } else {
                    completion(.failure(NetworkError.photoError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeRequest(for photoId: String, isLike: Bool) -> URLRequest {
        guard let token = OAuth2TokenStorage().token else { fatalError("No token provided") }
        
        guard var urlComponents = URLComponents(url: defaultBaseURL, resolvingAgainstBaseURL: false) else { fatalError() }
        urlComponents.path = "/photos/\(photoId)/like"
        let url = urlComponents.url!
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "DELETE" : "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String
    let welcomeDescription: String?
    let isLiked: Bool
    
    let urls: URLsResult
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case width = "width"
        case height = "height"
        case createdAt = "created_at"
        case welcomeDescription = "description"
        case isLiked = "liked_by_user"
        case urls = "urls"
    }
}

struct URLsResult: Decodable {
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
    let thumbImageURL: URL?
    let largeImageURL: URL?
    var isLiked: Bool
}

struct LikeResult: Decodable {
    let photo: PhotoResult
}
