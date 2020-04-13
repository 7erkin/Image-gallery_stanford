//
//  +ButtonPanelDelegate.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 13/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

extension GalleryPresenterViewController: GalleryFooterDelegate {
    func onCancelButtonTapped() {
        isChooseModeOn = false
    }
    
    func onDeleteButtonTapped() {
        deleteImages()
    }
}
