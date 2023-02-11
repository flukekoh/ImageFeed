//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Артем Кохан on 29.11.2022.
//

import Foundation
import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBAction private func likeButtonClicked() {
       delegate?.imageListCellDidTapLike(self)
    }
    
    weak var delegate: ImagesListCellDelegate?
    
    var gradient = CAGradientLayer()
    
    private enum ImageConstants {
        static let activeLikeImage = UIImage(named: "Active")
        static let noActiveLikeImage = UIImage(named: "No Active")
        static let colorTop =  UIColor(red: 26, green: 27, blue: 34, alpha: 0).cgColor
        static let colorBottom = UIColor(red: 26, green: 27, blue: 34, alpha: 0.2).cgColor
        static let stubImage = UIImage(named: "stub_image")
    }
    
    
    
    func setupCell(photo: Photo, completion: @escaping () -> Void) {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.colors = [ImageConstants.colorTop, ImageConstants.colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.dateLabel.bounds
        
        self.dateLabel.layer.insertSublayer(gradientLayer, at:0)
        
        gradient = GradientService.getGradient(size: self.cellImage.frame.size, cornerRadius: self.cellImage.layer.cornerRadius)
        
        self.cellImage.layer.addSublayer(gradient)
        
        self.cellImage.kf.setImage(with: photo.thumbImageURL, placeholder: ImageConstants.stubImage) { _, _ in
            completion()
            
            
        }
        self.gradient.removeFromSuperlayer()
        
        if let dateCreatedAt = photo.createdAt {
            self.dateLabel.text = DateFormatterService.shared.getDateToString(date: dateCreatedAt)
        } else {
            self.dateLabel.text = ""
        }
        
        setIsLiked(isLiked: photo.isLiked)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
    }
    
    func setIsLiked(isLiked: Bool) {
             let likeImage = isLiked ? ImageConstants.activeLikeImage : ImageConstants.noActiveLikeImage
             likeButton.setImage(likeImage, for: .normal)
         }
}
