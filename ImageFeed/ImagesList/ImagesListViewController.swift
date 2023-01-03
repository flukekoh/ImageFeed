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
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    @IBOutlet private var tableView: UITableView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
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
    
    
    
    
    
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
        
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.setupCell(indexPath: indexPath)
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

