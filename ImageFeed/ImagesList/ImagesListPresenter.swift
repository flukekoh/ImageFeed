//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Артем Кохан on 16.02.2023.
//

import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    private var imagesListServiceObserver: NSObjectProtocol?
    func viewDidLoad() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                guard let self else { return }
                self.view?.updateTableViewAnimated()
            }
        )
        
        ImagesListService.shared.fetchPhotosNextPage()
    }
    
    
}
