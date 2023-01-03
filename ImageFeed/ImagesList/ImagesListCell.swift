//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Артем Кохан on 29.11.2022.
//

import Foundation
import UIKit

class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    private enum ImageConstants {
        static let activeLikeImage = UIImage(named: "Active")
        static let noActiveLikeImage = UIImage(named: "No Active")
        static let colorTop =  UIColor(red: 26, green: 27, blue: 34, alpha: 0).cgColor
        static let colorBottom = UIColor(red: 26, green: 27, blue: 34, alpha: 0.2).cgColor
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    func setupCell(indexPath: IndexPath) {
        guard let cellImage = UIImage(named: "\(indexPath.row)") else {
            return
        }
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.colors = [ImageConstants.colorTop, ImageConstants.colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.dateLabel.bounds
        
        self.dateLabel.layer.insertSublayer(gradientLayer, at:0)
        
        self.cellImage.image = cellImage
        
        self.dateLabel.text = dateFormatter.string(from: Date())
        
        if indexPath.row % 2 == 0 {
            self.likeButton.imageView?.image = ImageConstants.noActiveLikeImage
        } else {
            self.likeButton.imageView?.image = ImageConstants.activeLikeImage
        }
    }
}
