//
//  +UICollectionViewDataSource.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 12/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

extension GalleryPresenterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.gallery?.data.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! GalleryPresenterViewCell
        cell.url = presenter.gallery.data.images[indexPath.row].data.url
        cell.delegate = self
        cell.isChooseModeOn = isChooseModeOn
        return cell
    }
}
