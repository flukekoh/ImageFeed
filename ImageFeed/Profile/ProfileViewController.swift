//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Артем Кохан on 10.12.2022.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
//    func updateProfileDetails(profile: Profile)
//    func showErrorAlert()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
//    func updateProfileDetails(profile: Profile) {
//        <#code#>
//    }
//
//    func showErrorAlert() {
//        <#code#>
//    }
    
    
    private var imageView = UIImageView()
    private var nameLabel = UILabel()
    private var loginLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var button: UIButton?
    
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    var presenter: ProfilePresenterProtocol?
    
    var gradientImageView = CAGradientLayer()
    var gradientNameLabel = CAGradientLayer()
    var gradientLoginLabel = CAGradientLayer()
    var gradientDescriptionLabel = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(named: "YPBlack")
        
        nameLabel.text = profileService.profile?.username
        loginLabel.text = profileService.profile?.username
        descriptionLabel.text = profileService.profile?.bio
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                guard let self else { return }
                self.updateAvatar()
            })
        
        addImageView()
        addNameLabel()
        addLoginLabel()
        addDescriptionLabel()
        addButtonView()
    }
    
    
    
//    func configure(_ presenter: ProfilePresenterProtocol) {
//        self.presenter = presenter
//        presenter.view = self
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if profileService.profile != nil {
            gradientImageView.removeFromSuperlayer()
            gradientNameLabel.removeFromSuperlayer()
            gradientLoginLabel.removeFromSuperlayer()
            gradientDescriptionLabel.removeFromSuperlayer()
        }
    }
    private func updateAvatar() {
        
        guard
            let profileImageUrl = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageUrl)
        else { return }
        
        imageView.kf.setImage(with: url)
        
    }
    
    
    func addImageView() {
        if let avatarURL = ProfileImageService.shared.avatarURL,
           let url = URL(string: avatarURL) {
            imageView.kf.setImage(with: url)
        }
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 35
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        gradientImageView = GradientService.getGradient(size: CGSize(width: 70, height: 70), cornerRadius: 35)
        
        imageView.layer.addSublayer(gradientImageView)
        
        view.addSubview(imageView)
        
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        
    }
    
    func addNameLabel() {
        
        nameLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        nameLabel.textColor = UIColor(named: "YPWhite")
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        gradientNameLabel = GradientService.getGradient(size: CGSize(width: 223, height: 25), cornerRadius: 9)
        
        nameLabel.layer.addSublayer(gradientNameLabel)
        
        view.addSubview(nameLabel)
        
        nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
    }
    
    func addLoginLabel() {
        
        loginLabel.font = UIFont(name: "YSDisplay-Medium", size: 13)
        loginLabel.textColor = UIColor(named: "YPGray")
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        
        gradientLoginLabel = GradientService.getGradient(size: CGSize(width: 89, height: 18), cornerRadius: 9)
        
        loginLabel.layer.addSublayer(gradientLoginLabel)
        
        view.addSubview(loginLabel)
        
        loginLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true
        loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        loginLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
    }
    
    func addDescriptionLabel() {
        
        descriptionLabel.font = UIFont(name: "YSDisplay-Medium", size: 13)
        descriptionLabel.textColor = UIColor(named: "YPWhite")
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        gradientDescriptionLabel = GradientService.getGradient(size: CGSize(width: 67, height: 18), cornerRadius: 9)
        
        descriptionLabel.layer.addSublayer(gradientDescriptionLabel)
        
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
        
        guard let alert = presenter?.getAlert() else { return }
        present(alert, animated: true)
    }
    
    
    
}
