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
    
    private let parameterNamePage: String = "page"
    private let parameterNamePerPage: String = "per_page"
    private let parameterNameOrderBy: String = "order_by"
    
    private enum NetworkError: Error {
        case codeError
        case photoError
    }
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard task == nil else { return }
        let nextPage = lastLoadedPage == 0 ? 1 : lastLoadedPage + 1
        
        let request = makeRequest(page: nextPage)
        guard let request = request else { return }
        
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
        Photo(id: photo.id, size: CGSize(width: photo.width, height: photo.height), createdAt: DateFormatterService.shared.isoFormatter.date(from: photo.createdAt), welcomeDescription: photo.welcomeDescription, thumbImageURL: URL(string: photo.urls.thumb) , largeImageURL: URL(string: photo.urls.full), isLiked: photo.isLiked)
    }
    
    private func makeRequest(page: Int) -> URLRequest? {
        
        guard let token = OAuth2TokenStorage.shared.token else {
            assertionFailure("No token saved")
            return nil
        }
        
        guard var urlComponents = URLComponents(url: DefaultBaseURL, resolvingAgainstBaseURL: false) else {
            assertionFailure("Invalid URL")
            return nil
        }
        urlComponents.path = "/photos"
        urlComponents.queryItems = [
            URLQueryItem(name: parameterNamePage, value: "\(page)"),
            URLQueryItem(name: parameterNamePerPage, value: "\(perPage)"),
            URLQueryItem(name: parameterNameOrderBy, value: "\(orderBy)")
        ]
        guard let url = urlComponents.url else {
            assertionFailure("Invalid url")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        let request = makeRequest(for: photoId, isLike: isLike)
        guard let request = request else { return }
        
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
    
    private func makeRequest(for photoId: String, isLike: Bool) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token else {
            assertionFailure("No token saved")
            return nil
        }
        
        guard var urlComponents = URLComponents(url: DefaultBaseURL, resolvingAgainstBaseURL: false) else {
            assertionFailure("Invalid url")
            return nil
        }
        urlComponents.path = "/photos/\(photoId)/like"
        guard let url = urlComponents.url else {
            assertionFailure("Invalid url")
            return nil
        }
        
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
