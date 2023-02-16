//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Артем Кохан on 26.01.2023.
//

import Foundation
import UIKit

final class TabBarController: UITabBarController {
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        
        let imagesListPresenter = ImagesListPresenter()
        imagesListViewController.presenter = imagesListPresenter
        imagesListPresenter.view = imagesListViewController
        
        let profileViewController = ProfileViewController()
        
        let profileViewPresenter = ProfilePresenter()
        profileViewController.presenter = profileViewPresenter
        profileViewPresenter.view = profileViewController
        
        profileViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("", comment: ""), image: UIImage(named: "tab_profile_active"), selectedImage: nil)
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
