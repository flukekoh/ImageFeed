//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Артем Кохан on 27.12.2022.
//

import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oauth2Service = OAuth2Service()
    
    private let profileService = ProfileService.shared
    
    private var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addImageView()
        
        guard let token = OAuth2TokenStorage.shared.token else { return }
        fetchProfile(token: token)
    }
    
    private func addImageView() {
        
        let logoImage = UIImage(named: "splash_screen_logo")
        imageView.image = logoImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = UIColor.init(named: "YPBlack")
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor), imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if OAuth2TokenStorage.shared.token == nil {
            routeToAuth()
        }
    }
    
    func routeToAuth() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let authViewController = storyboard.instantiateViewController(
            withIdentifier: "AuthViewController"
        ) as? AuthViewController else { return }
        
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            UIBlockingProgressHUD.show()
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let token):
                OAuth2TokenStorage.shared.token = token
                self.fetchProfile(token: token)
            case .failure:
                self.showAlert()
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.profileResult.username, token: token) { _ in }
                self?.switchToTabBarController()
            case .failure:
                self?.showAlert()
            }
        }
    }
}

extension SplashViewController {
    private func showAlert() {
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            buttonText: "Ок") { [weak self] in
                guard let self = self else { return }
                self.routeToAuth()
            }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            var alertPresenter = AlertPresenter(alertModel: alertModel)
            alertPresenter.viewController = self
            alertPresenter.requestAlert()
        }
    }
}
