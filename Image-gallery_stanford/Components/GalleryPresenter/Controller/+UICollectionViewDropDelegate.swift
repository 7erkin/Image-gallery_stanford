//
//  +UICollectionViewDropDelegate.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 12/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

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
        let indexFrom = item.sourceIndexPath!.row
        let indexTo = coordinator.destinationIndexPath!.row
        presenter.moveImage(byIndex: indexFrom, toIndex: indexTo)
    }

    private func performExternalDrop(_ item: UICollectionViewDropItem, _ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
        
        _ = item.dragItem.itemProvider.loadObject(ofClass: URL.self) { [weak self] (provider, error) in
            if let url = provider, let imageUrl = url.imageURL {
                self?.presenter.addImage(byIndex: destinationIndexPath.row, withUrl: imageUrl)
            }
        }
    }
}
