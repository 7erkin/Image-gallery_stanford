//
//  +UICollectionViewDragDelegate.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 12/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

extension GalleryPresenterViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: NSAttributedString()) // mock in object. Pass smth - have no sence, so what to pass then?
        let dragItem = UIDragItem(itemProvider: itemProvider)
        session.localContext = collectionView
        return [dragItem]
    }
}
