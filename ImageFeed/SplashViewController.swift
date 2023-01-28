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
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    private let profileService = ProfileService.shared
    
    private var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addImageView()
    }
    
    private func addImageView() {
        
        let logoImage = UIImage(named: "splash_screen_logo")
        imageView.image = logoImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor), imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getProfile()
    }
    
    func getProfile() {
        if let token = oauth2TokenStorage.token {
            fetchProfile(token: token)
            switchToTabBarController()
        } else {
            
            let authViewController = AuthViewController()
            authViewController.delegate = self
            
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true)
        }
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
        UIBlockingProgressHUD.show()
        
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
                self.oauth2TokenStorage.token = token
                self.switchToTabBarController()
                self.fetchProfile(token: token)
                //                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                // TODO [Sprint 11]
                break
            }
        }
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            //            guard let self = self else { return }
            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.profileResult.username, token: token) { _ in }
                
                UIBlockingProgressHUD.dismiss()
                //                self.switchToTabBarController()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self?.showAlert()
                break
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
                 self.getProfile()
             }

         DispatchQueue.main.async { [weak self] in
             guard let self = self else { return }
             var alertPresenter = AlertPresenter(alertModel: alertModel)
             alertPresenter.viewController = self
             
             alertPresenter.requestAlert()
             UIBlockingProgressHUD.dismiss()
         }

     }
 }
