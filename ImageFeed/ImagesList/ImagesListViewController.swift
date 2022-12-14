//
//  ViewController.swift
//  ImageFeed
//
//  Created by Артем Кохан on 21.11.2022.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        
        photosName = Array(0..<20).map{ "\($0)" }
    }
    
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    @IBOutlet private var tableView: UITableView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            let imageName = photosName[indexPath.row]
            let image = UIImage(named: "\(imageName)_full_size") ?? UIImage(named: imageName)
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    private var photosName = [String]()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private let activeLikeImage = UIImage(named: "Active")
    private let noActiveLikeImage = UIImage(named: "No Active")
    
    let colorTop =  UIColor(red: 26, green: 27, blue: 34, alpha: 0).cgColor
    let colorBottom = UIColor(red: 26, green: 27, blue: 34, alpha: 0.2).cgColor
    
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
        
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        guard let cellImage = UIImage(named: "\(indexPath.row)") else {
            return
        }
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = cell.dateLabel.bounds
        
        cell.dateLabel.layer.insertSublayer(gradientLayer, at:0)
        
        cell.cellImage.image = cellImage
        
        cell.dateLabel.text = dateFormatter.string(from: Date())
        
        if indexPath.row % 2 == 0 {
            cell.likeButton.imageView?.image = noActiveLikeImage
        } else {
            cell.likeButton.imageView?.image = activeLikeImage
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

