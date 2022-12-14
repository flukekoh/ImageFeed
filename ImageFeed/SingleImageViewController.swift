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
            
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet weak var SingleImageScrollView: UIScrollView!
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = SingleImageScrollView.minimumZoomScale
        let maxZoomScale = SingleImageScrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = SingleImageScrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        SingleImageScrollView.setZoomScale(scale, animated: false)
        SingleImageScrollView.layoutIfNeeded()
        let newContentSize = SingleImageScrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        SingleImageScrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SingleImageScrollView.minimumZoomScale = 0.1
        SingleImageScrollView.maximumZoomScale = 1.25
        
        imageView.image = image
        
        rescaleAndCenterImageInScrollView(image: image)
        
    }
}
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    
}


