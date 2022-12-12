//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Артем Кохан on 10.12.2022.
//

import Foundation
import UIKit

class SingleImageViewController: UIViewController {
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
    }
}
