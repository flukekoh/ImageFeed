//
//  ImageListViewTests.swift
//  ImageFeedTests
//
//  Created by Артем Кохан on 15.02.2023.
//

import Foundation

import XCTest
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var viewDidLoadCalled = false
    var view: ImagesListViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}

final class ImagesListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //Given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        //When
        _ = viewController.view
        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}
