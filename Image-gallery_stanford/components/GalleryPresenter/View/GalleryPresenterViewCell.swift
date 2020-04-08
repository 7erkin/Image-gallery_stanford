//
//  ImageGalleryCollectionViewCell.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 15/03/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

class GalleryPresenterViewCell: UICollectionViewCell {
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    private var image: UIImage? { didSet { setNeedsDisplay() } }
    
    var url: URL! {
        didSet {
            loadingIndicator.startAnimating()
            let imageUrl: URL = self.url
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                if let data = try? Data(contentsOf: imageUrl) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            if imageUrl == self?.url {
                                self?.image = image
                                self?.loadingIndicator.stopAnimating()
                            }
                        }
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        contentMode = .redraw
        backgroundColor = .gray
        clearsContextBeforeDrawing = true
    }
    
    override func draw(_ rect: CGRect) {
        image?.draw(in: rect)
    }
}
