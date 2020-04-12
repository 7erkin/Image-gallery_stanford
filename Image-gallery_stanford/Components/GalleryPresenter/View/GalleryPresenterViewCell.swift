//
//  ImageGalleryCollectionViewCell.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 15/03/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

@IBDesignable
class ChoiceIndicator: UIView {
    @IBInspectable
    var isActive: Bool = false {
        didSet { setNeedsDisplay() }
    }
    
    private var lineWidth: CGFloat = 2.0
    
    override func draw(_ rect: CGRect) {
        var path = UIBezierPath(
            arcCenter: .init(x: bounds.midX, y: bounds.midY),
            radius: rect.width / 2 - lineWidth,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        UIColor.systemBlue.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
        if isActive {
            let rect = rect.insetBy(dx: lineWidth + 3, dy: lineWidth + 3)
            path = UIBezierPath(roundedRect: rect, cornerRadius: rect.width / 2)
            UIColor.systemBlue.setFill()
            path.fill()
        }
    }
}

protocol CellGestureDelegate: class {
    func tapHappened(sender: GalleryPresenterViewCell)
    func longPressHappened(sender: GalleryPresenterViewCell)
}

class GalleryPresenterViewCell: UICollectionViewCell {
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var choiceIndicator: ChoiceIndicator! {
        didSet {
            self.choiceIndicator.isHidden = true
        }
    }
    
    weak var delegate: CellGestureDelegate!
    
    override func awakeFromNib() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTappedGestureHappened))
        self.addGestureRecognizer(tapGesture)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGestureHappened(sender:)))
        self.addGestureRecognizer(longPressGesture)
    }
    
    @objc
    func onTappedGestureHappened(sender: UITapGestureRecognizer) {
        delegate.tapHappened(sender: self)
        delegate.longPressHappened(sender: self)
    }
    @objc
    func onLongPressGestureHappened(sender: UILongPressGestureRecognizer) {
        delegate.longPressHappened(sender: self)
    }
    
    var isChooseModeOn: Bool = false {
        didSet {
            self.choiceIndicator.isHidden = !self.isChooseModeOn
            if self.isChooseModeOn {
                self.choiceIndicator.isActive = false
            }
        }
    }
    
    var isChoosen: Bool = false {
        didSet {
            choiceIndicator.isActive = self.isChoosen
        }
    }
    
    var url: URL! {
        didSet {
            loadingIndicator.startAnimating()
            let url: URL! = self.url
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
