//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Артем Кохан on 10.12.2022.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {
    
    private var imageView = UIImageView()
    private var nameLabel = UILabel()
    private var loginLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var button: UIButton?
    
    override func viewDidLoad() {
        addImageView()
        addNameLabel()
        addLoginLabel()
        addDescriptionLabel()
        addButtonView()
    }
    
    func addImageView() {
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
        
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = .systemFont(ofSize: 23, weight: .medium)
        nameLabel.textColor = UIColor(named: "YPWhite")
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(nameLabel)
        
        nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
    }
    
    func addLoginLabel() {
        loginLabel.text = "@ekaterina_nov"
        loginLabel.font = .systemFont(ofSize: 13)
        loginLabel.textColor = UIColor(named: "YPGray")
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(loginLabel)
        
        loginLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true
        loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        loginLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
    }
    
    func addDescriptionLabel() {
        descriptionLabel.text = "Hello, World!"
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
