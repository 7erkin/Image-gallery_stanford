//
//  +GalleryPresenterObserver.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 12/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

extension GalleryPresenterViewController: GalleryPresenterObserver {
    func notify(with events: [GalleryPresenter.Event]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            for event in events {
                switch event {
                case .galleryFetched:
                    self.fetchingImagesIndicator.stopAnimating()
                    self.collectionView.reloadData()
                    fallthrough
                case .galleryNameUpdated:
                    self.navigationItem.title = self.presenter.gallery.data.name
                case .imageMoved(let indexFrom, let indexTo):
                    // important moment!
                    self.collectionView.performBatchUpdates({
                        self.collectionView.insertItems(at: [.init(row: indexTo, section: 0)])
                        self.collectionView.deleteItems(at: [.init(row: indexFrom, section: 0)])
                    }, completion: nil)
                case .imageAdded(let indexTo):
                    self.collectionView.performBatchUpdates({
                        self.collectionView.insertItems(at: [.init(row: indexTo, section: 0)])
                    }, completion: nil)
                case .imagesDeleted(let indices):
                    self.collectionView.performBatchUpdates({
                        self.choosenImageIndices.removeAll()
                        self.collectionView.deleteItems(at: indices.map { IndexPath(row: $0, section: 0) })
                        self.isChooseModeOn = false
                    }, completion: nil)
                default:
                    break
                }
            }
        }
    }
}
