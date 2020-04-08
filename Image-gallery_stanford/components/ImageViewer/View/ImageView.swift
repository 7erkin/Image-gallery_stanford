//
//  ImageView.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 16/03/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

class ImageView: UIView {
    var image: UIImage! {
        didSet {
            setNeedsDisplay()
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
    }
    
    override func draw(_ rect: CGRect) {
        if image != nil {
            image.draw(in: rect)
        }
    }
}
