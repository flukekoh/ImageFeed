//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Артем Кохан on 16.02.2023.
//

import Foundation
import UIKit

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func getAlert() -> UIAlertController
    func viewDidLoad()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {}
    
    func getAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: .alert
        )
        
        let agreeAction = UIAlertAction(
            title: "Да",
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.onLogout()
            }
        }
        
        let dismissAction = UIAlertAction(
            title: "Нет",
            style: .default
        )
        
        alert.addAction(agreeAction)
        alert.addAction(dismissAction)
        
        return alert
    }
    
    private func onLogout() {
        OAuth2TokenStorage().clearToken()
        WebViewViewController.clean()
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid configuration")
            return
        }
        window.rootViewController = SplashViewController()
    }
    
}
