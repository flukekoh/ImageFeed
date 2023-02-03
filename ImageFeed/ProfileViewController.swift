//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Артем Кохан on 10.12.2022.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private var imageView = UIImageView()
    private var nameLabel = UILabel()
    private var loginLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var button: UIButton?
    
    private let profileService = ProfileService.shared
    
    override func viewDidLoad() {
       
        nameLabel.text = profileService.profile?.username
        loginLabel.text = profileService.profile?.username
        descriptionLabel.text = profileService.profile?.bio
        
        if let avatarURL = ProfileImageService.shared.avatarURL,// 16
           let url = URL(string: avatarURL) {                   // 17
       
            addImageView(url: url)
        }

        addNameLabel()
        addLoginLabel()
        addDescriptionLabel()
        addButtonView()
          
    }
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        addObserver()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addObserver()
    }
    
    deinit {
        removeObserver()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(                 // 1
            self,                                               // 2
            selector: #selector(updateAvatar(notification:)),   // 3
            name: ProfileImageService.didChangeNotification,    // 4
            object: nil)                                        // 5
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(              // 6
            self,                                               // 7
            name: ProfileImageService.didChangeNotification,    // 8
            object: nil)                                        // 9
    }
    
    @objc                                                       // 10
    private func updateAvatar(notification: Notification) {     // 11
        guard
            isViewLoaded,                                       // 12
            let userInfo = notification.userInfo,               // 13
            let profileImageURL = userInfo["URL"] as? String,   // 14
            let url = URL(string: profileImageURL)              // 15
        else { return }
        
    }
    
    func addImageView(url: URL) {
        imageView.kf.setImage(with: url)
        let profileImage = UIImage(named: "Userpic")
        imageView.image = profileImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    }
    
    func addNameLabel() {

        nameLabel.font = .systemFont(ofSize: 23, weight: .medium)
        nameLabel.textColor = UIColor(named: "YPWhite")
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(nameLabel)
        
        nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
    }
    
    func addLoginLabel() {

        loginLabel.font = .systemFont(ofSize: 13)
        loginLabel.textColor = UIColor(named: "YPGray")
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(loginLabel)
        
        loginLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true
        loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        loginLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
    }
    
    func addDescriptionLabel() {

        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = UIColor(named: "YPWhite")
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(descriptionLabel)
        
        descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
    }
    
    func addButtonView() {
        var button = UIButton.systemButton(with: UIImage(named: "Exitpic") ?? UIImage(), target: self, action: #selector(self.didTapLogoutButton))
        
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        self.button = button
        
        view.addSubview(button)
        
        button.leadingAnchor.constraint(greaterThanOrEqualTo: imageView.trailingAnchor).isActive = true
        button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56).isActive = true
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
    }
    
    @objc func didTapLogoutButton(_ sender: Any) {
    }
}
