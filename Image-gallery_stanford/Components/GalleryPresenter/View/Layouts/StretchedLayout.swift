//
//  StretchedLayout.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 11/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

// 3 up 2 down
class StretchedLayout: UICollectionViewLayout {
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var collectionViewHeight: CGFloat { collectionView!.bounds.height }
    private var collectionViewWidth: CGFloat { collectionView!.bounds.width }
    private var stretchedCellSize: CGSize { .init(width: (collectionViewWidth - 2 * itemSpacing) / 3, height: (collectionViewHeight * 3 - 2 * rowSpacing) / 10) }
    private var compressedCellSize: CGSize { .init(width: (collectionViewWidth - itemSpacing) / 2, height: (collectionViewHeight * 2 - 2 * rowSpacing) / 10) }
    private var itemSpacing: CGFloat = 2.0
    private var rowSpacing: CGFloat = 2.0
    private var footerHeight: CGFloat = 50.0
    
    private var collectionViewContentHeight: CGFloat = .zero
    override var collectionViewContentSize: CGSize {
        return .init(width: collectionViewWidth, height: collectionViewHeight)
    }
    
    override func prepare() {
        let xStretchedCellShifts = Array(stride(from: 0, to: collectionViewWidth, by: stretchedCellSize.width + itemSpacing))
        let xCompressedCellShifts = Array(stride(from: 0, to: collectionViewWidth, by: compressedCellSize.width + itemSpacing))
        var yShift: CGFloat = .zero
        // repeat from layout to layout
        let footerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: IndexPath(row: 0, section: 0))
        footerAttributes.frame = CGRect(
            origin: .init(x: 0, y: collectionView!.bounds.maxY - footerHeight),
            size: .init(width: collectionView!.bounds.width, height: footerHeight)
        )
        cache.append(footerAttributes)
        //
        for number in (0..<collectionView!.numberOfItems(inSection: 0)) {
            let modNumber = number % 5
            let attributes = UICollectionViewLayoutAttributes(forCellWith: .init(item: number, section: 0))
            var frame: CGRect = .zero
            if modNumber < 3 {
                frame = CGRect(origin: CGPoint(x: xStretchedCellShifts[modNumber], y: yShift), size: stretchedCellSize)
            } else {
                if modNumber == 3 { yShift += (stretchedCellSize.height + rowSpacing) }
                frame = CGRect(origin: CGPoint(x: xCompressedCellShifts[modNumber % 3], y: yShift), size: compressedCellSize)
                if modNumber == 4 { yShift += (compressedCellSize.height + rowSpacing) }
            }
            attributes.frame = frame
            cache.append(attributes)
        }
        if let lastAttributes = cache.last {
            collectionViewContentHeight = lastAttributes.frame.origin.y + lastAttributes.frame.height
        } else {
            collectionViewContentHeight = yShift
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter({ $0.frame.intersects(rect) })
    }
}
