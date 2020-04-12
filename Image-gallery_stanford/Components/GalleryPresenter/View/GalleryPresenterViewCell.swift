//
//  ImageGalleryCollectionViewCell.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 15/03/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

var id = 1

class GalleryPresenterViewCell: UICollectionViewCell {
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var imageView: UIImageView!
    
    var url: URL! {
        didSet {
            loadingIndicator.startAnimating()
            self.url = URL(string: "https://images.pexels.com/photos/132340/pexels-photo-132340.jpeg?cs=srgb&dl=turned-on-pendant-lamp-132340.jpg&fm=jpg")!
            let url: URL! = URL(string: "https://images.pexels.com/photos/132340/pexels-photo-132340.jpeg?cs=srgb&dl=turned-on-pendant-lamp-132340.jpg&fm=jpg")!
            Utils.fetchImage(byUrl: url) { (res, image) in
                DispatchQueue.main.async { [weak self] in
                    if let self = self, url == self.url {
                        self.imageView.image = image
                    } else {
                        // inform user about download error
                    }
                    self?.loadingIndicator.stopAnimating()
                }
            }
        }
    }
}
