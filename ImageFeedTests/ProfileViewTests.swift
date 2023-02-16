//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Артем Кохан on 15.02.2023.
//

import XCTest
@testable import ImageFeed


final class ProfileViewPresenterSpy: ProfilePresenterProtocol {
    
    var viewDidLoadCalled = false
    var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func getAlert() -> UIAlertController {
        UIAlertController()
    }
}

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}
