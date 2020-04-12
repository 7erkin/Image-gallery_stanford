//
//  ViewController.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 15/03/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

class GalleryPresenterViewController: UIViewController, UICollectionViewDelegate {
    var presenter: GalleryPresenter! {
        didSet { self.presenter.subscribe(self) }
    }
    
    var isChooseModeOn: Bool = false {
        didSet {
            (collectionView.visibleCells as! [GalleryPresenterViewCell]).forEach { $0.isChooseModeOn = true }
        }
    }
    
    var choosenImageIndices: Set<Int> = []
    
    @IBOutlet var deleteImagesButton: UIBarButtonItem!
    
    @IBAction func onDeleteButtonTapped(_ sender: Any) {
        presenter.deleteImages(byIndices: Array(choosenImageIndices))
    }
    
    @IBAction func switchLayout(_ sender: Any) {
        let layout = LayoutFactory.createNextLayout()
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    @IBOutlet var fetchingImagesIndicator: UIActivityIndicatorView!
    
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            self.collectionView.dataSource = self
            self.collectionView.dropDelegate = self
            self.collectionView.delegate = self
            self.collectionView.dragDelegate = self
        }
    }
    
    private lazy var placeholderView: UIView = {
        let view = UIView(frame: self.collectionView.bounds)
        view.backgroundColor = .blue
        let text = NSAttributedString(string: "Choose gallery or add new gallery", attributes: [
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body).withSize(40),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = text
        view.addSubview(label)
        label.sizeToFit()
        label.frame = view.frame.insetBy(dx: 20, dy: 0)
        label.center = CGPoint(x: view.bounds.midX, y: view.bounds.height / 3)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = LayoutFactory.createNextLayout()
        collectionView.collectionViewLayout = layout
        if presenter == nil {
            self.collectionView.backgroundView = placeholderView
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if presenter != nil {
            fetchingImagesIndicator.startAnimating()
            presenter.fetchGallery()
        }
    }
}
