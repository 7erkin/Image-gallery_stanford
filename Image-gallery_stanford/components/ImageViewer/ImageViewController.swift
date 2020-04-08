//
//  ImageViewController.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 15/03/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    var image: UIImage! {
        didSet {
            if scrollView != nil, imageView != nil {
                setup()
            }
        }
    }
    
    @IBOutlet var scrollViewWidth: NSLayoutConstraint!
    @IBOutlet var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView! {
        didSet {
            self.scrollView.delegate = self
            self.scrollView.maximumZoomScale = 2.0
            self.scrollView.minimumZoomScale = 0.5
        }
    }
    private var imageView = ImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if image != nil {
            setup()
        }
    }
    
    private func setup() {
        imageView.image = image
        imageView.frame = CGRect(origin: .zero, size: image.size)
        scrollView.addSubview(imageView)
        scrollView.contentSize = image.size
        scrollViewWidth.constant = image.size.width
        scrollViewHeight.constant = image.size.height
    }
    
    // MARK: UIScrollViewDelegate impl
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewHeight.constant = scrollView.contentSize.height
        scrollViewWidth.constant = scrollView.contentSize.width
    }
}
