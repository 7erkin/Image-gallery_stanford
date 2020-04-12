//
//  +CellGestureDelegate.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 12/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

extension GalleryPresenterViewController: CellGestureDelegate {
    func tapHappened(sender: GalleryPresenterViewCell) {
        if isChooseModeOn {
            sender.isChoosen = !sender.isChoosen
            let imageIndex = collectionView.indexPath(for: sender)!.row
            if sender.isChoosen {
                choosenImageIndices.insert(imageIndex)
            } else {
                choosenImageIndices.remove(imageIndex)
            }
        } else {
            // go to scroll view
        }
    }
    
    func longPressHappened(sender: GalleryPresenterViewCell) {
        if !isChooseModeOn {
            isChooseModeOn = true
            sender.isChoosen = true
            let index = collectionView.indexPath(for: sender)!.row
            choosenImageIndices.insert(index)
        }
    }
}
