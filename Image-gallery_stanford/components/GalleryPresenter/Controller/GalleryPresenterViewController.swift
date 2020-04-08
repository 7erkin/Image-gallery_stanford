//
//  ViewController.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 15/03/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

/* Need to make cool layout */
private class ImageGalleryLayout {
    private var indexColumnCount: Int
    private var availableColumnCount: [Int]
    var columns: Int {
        return availableColumnCount[indexColumnCount]
    }
    init(availableColumnCount: [Int], indexInitialColumnCount: Int) {
        indexColumnCount = indexInitialColumnCount
        self.availableColumnCount = availableColumnCount
    }
    func imageWidth(boundsWidth width: CGFloat) -> CGFloat {
        return (width - CGFloat(columns - 1) * spaceBetweenColumns(boundsWidth: width)) / CGFloat(columns)
    }
    func spaceBetweenColumns(boundsWidth width: CGFloat) -> CGFloat {
        return 10
    }
    func spaceBetweenRows(boundsWidth width: CGFloat) -> CGFloat {
        return 10
    }
    func increaseColumns() {
        if indexColumnCount + 1 < availableColumnCount.count {
            indexColumnCount += 1
        }
    }
    func descreaseColumns() {
        if indexColumnCount != 0 {
            indexColumnCount -= 1
        }
    }
}

class GalleryPresenterViewController: UIViewController, UICollectionViewDelegate,
UICollectionViewDataSource, UICollectionViewDropDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate {
    var imageGallery: ImageGallery! {
        didSet {
            navigationItem.title = self.imageGallery.name
            self.imageGallery.update += [{[weak self] whatHappened in
                DispatchQueue.main.async {
                    for evt in whatHappened {
                        switch evt {
                            case .added(let index):
                                break
                            case .removed(let index):
                                break
                            case .renamed:
                                self?.navigationItem.title = self?.imageGallery.name
                                break
                            case .swapped(let firstIndex, let secondIndex):
                                break
                        case .deleted:
                            break
                        }
                    }
                }
            }]
        }
    }
    
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            self.collectionView.dataSource = self
            self.collectionView.dropDelegate = self
            self.collectionView.delegate = self
            self.collectionView.dragDelegate = self
            
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(onPinchHappened(_:)))
            self.collectionView.addGestureRecognizer(pinchGesture)
        }
    }
    private var galleryLayout = ImageGalleryLayout(availableColumnCount: [1] + stride(from: 2, to: 10, by: 2), indexInitialColumnCount: 3)
    
    @objc
    func onPinchHappened(_ gesture: UIPinchGestureRecognizer) {
        if gesture.scale > 1.5 {
            galleryLayout.descreaseColumns()
            collectionView.collectionViewLayout.invalidateLayout()
            gesture.scale = 1.0
        }
        
        if gesture.scale < 0.5 {
            galleryLayout.increaseColumns()
            collectionView.collectionViewLayout.invalidateLayout()
            gesture.scale = 1.0
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
        if imageGallery == nil {
            self.collectionView.backgroundView = placeholderView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let imageWidth = galleryLayout.imageWidth(boundsWidth: collectionView.bounds.size.width)
        let imageHeight = CGFloat(imageGallery.images[indexPath.row].aspectRatio) * imageWidth
        return .init(width: imageWidth, height: imageHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return galleryLayout.spaceBetweenColumns(boundsWidth: collectionView.bounds.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return galleryLayout.spaceBetweenRows(boundsWidth: collectionView.bounds.width)
    }
    
    // MARK: - UICollectionViewDataSource impl
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageGallery?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! GalleryPresenterViewCell
        cell.url = imageGallery.images[indexPath.row].url
        return cell
    }
    
    // MARK: - UICollectionViewDropDelegate
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        for item in coordinator.items {
            let handler = item.sourceIndexPath == nil ? performExternalDrop : performInternalDrop
            handler(item, collectionView, coordinator)
        }
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
                        let imageItem = ImageItem(url: imageUrl, aspectRatio: aspectRatio)
                        self.imageGallery.add(imageItem, at: indexPath.row)
                    }
                } else {
                    placeholderContext.deletePlaceholder()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let operation: UIDropOperation = (session.localDragSession?.localContext as? UICollectionView) == collectionView ? .move : .copy
        return UICollectionViewDropProposal(operation: operation, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: URL.self) || session.canLoadObjects(ofClass: UIImage.self)
    }
    
    // MARK: - UICollectionViewDragDelegate impl
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
