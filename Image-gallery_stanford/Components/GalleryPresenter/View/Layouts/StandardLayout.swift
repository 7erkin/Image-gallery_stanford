//
//  StandardLayout.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 12/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

class StandardLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
    }
    
    override func prepare() {
        minimumLineSpacing = 2.0
        minimumInteritemSpacing = 1.0
        itemSize = .init(
            width: collectionView!.bounds.width / 3 - 2 * minimumInteritemSpacing,
            height: collectionView!.bounds.height / 3 - 2 * minimumInteritemSpacing
        )
        super.prepare()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
