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

extension GalleryPresenterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.gallery?.data.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! GalleryPresenterViewCell
        cell.url = presenter.gallery.data.images[indexPath.row].data.url
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
        let isLocalSession = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return session.canLoadObjects(ofClass: URL.self) || isLocalSession
    }

    private func performInternalDrop(_ item: UICollectionViewDropItem, _ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {

    }

    private func performExternalDrop(_ item: UICollectionViewDropItem, _ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
        
        _ = item.dragItem.itemProvider.loadObject(ofClass: URL.self) { (provider, error) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let url = provider {
                }
            }
        }
    }
}

extension GalleryPresenterViewController: GalleryPresenterObserver {
    func notify(with events: [GalleryPresenter.Event]) {
        for event in events {
            switch event {
            case .galleryFetched:
                fetchingImagesIndicator.stopAnimating()
                collectionView.reloadData()
                fallthrough
            case .galleryNameUpdated:
                navigationItem.title = presenter.gallery.data.name
            default:
                break
            }
        }
    }
}
