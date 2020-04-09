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
    
    @IBOutlet var fetchingImageIndicator: UIActivityIndicatorView! {
        didSet {
            self.fetchingImageIndicator.hidesWhenStopped = true
        }
    }
    
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            self.collectionView.isHidden = true
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
        label.attributedText = text
        view.addSubview(label)
        label.sizeToFit()
        label.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if presenter == nil {
            self.collectionView.backgroundView = placeholderView
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if presenter != nil {
            fetchingImageIndicator.startAnimating()
            presenter.fetchInitialData()
        }
    }
}

extension GalleryPresenterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! GalleryPresenterViewCell
        cell.url = presenter.images[indexPath.row].data.url
        return cell
    }
}

extension GalleryPresenterViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: NSAttributedString()) // mock in object. Pass smth - have no sence, so what to pass then?
        let dragItem = UIDragItem(itemProvider: itemProvider)
        session.localContext = collectionView
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension GalleryPresenterViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        for item in coordinator.items {
            let handler = item.sourceIndexPath == nil ? performExternalDrop : performInternalDrop
            handler(item, collectionView, coordinator)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let operation: UIDropOperation = (session.localDragSession?.localContext as? UICollectionView) == collectionView ? .move : .copy
        return UICollectionViewDropProposal(operation: operation, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: URL.self) || session.canLoadObjects(ofClass: UIImage.self)
    }
        
    private func performInternalDrop(_ item: UICollectionViewDropItem, _ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
            
    }
        
    private func performExternalDrop(_ item: UICollectionViewDropItem, _ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
        let placeholderCell = UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "PlaceholderCell")
        let placeholderContext = coordinator.drop(item.dragItem, to: placeholderCell)
            
        // Weird decision
        var aspectRatio: Float?
        var imageUrl: URL?
        item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
            DispatchQueue.main.async {
                if let image = provider as? UIImage {
                    aspectRatio = image.aspectRatio
                }
            }
        }
        _ = item.dragItem.itemProvider.loadObject(ofClass: URL.self) { (provider, error) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let url = provider {
                    imageUrl = url.imageURL
                }
                    
                if let aspectRatio = aspectRatio, let imageUrl = imageUrl {
                    /* IF UPDATING DATASOURCE IS ASYNC?!?!?! */
                    placeholderContext.commitInsertion { indexPath in
    //                       let imageItem = ImageItem(url: imageUrl, aspectRatio: aspectRatio)
    //                       self.imageGallery.add(imageItem, at: indexPath.row)
                    }
                } else {
                    placeholderContext.deletePlaceholder()
                }
            }
        }
    }
}

extension GalleryPresenterViewController: GalleryPresenterObserver {
    func notify(with events: [GalleryPresenter.Event]) {
        for event in events {
            switch event {
            case .galleryNameUpdated:
                navigationItem.title = presenter.galleryName
            default:
                break
            }
        }
    }
}
