//
//  TwoVerticalLayout.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 12/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

class TwoDifferentCellInRowLayout: UICollectionViewLayout {
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var collectionViewHeight: CGFloat { collectionView!.bounds.height }
    private var collectionViewWidth: CGFloat { collectionView!.bounds.width }
    private var bigCellSize: CGSize {
        .init(width: 6 * collectionViewWidth / 10 - itemSpacing / 2,
              height: collectionViewHeight / 4 - rowSpacing / 2
        )
    }
    private var smallCellSize: CGSize {
        .init(width: 4 * collectionViewWidth / 10 - itemSpacing / 2,
              height: collectionViewHeight / 4 - rowSpacing / 2
        )
    }
    private var itemSpacing: CGFloat = 2.0
    private var rowSpacing: CGFloat = 2.0
    private var footerHeight: CGFloat = 50.0
    
    private var collectionViewContentHeight: CGFloat = .zero
    override var collectionViewContentSize: CGSize {
        return .init(width: collectionViewWidth, height: collectionViewHeight)
    }
    
    override func prepare() {
        var yShift = CGFloat.zero
        let itemsCount = collectionView!.numberOfItems(inSection: 0)
        let footerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: IndexPath(row: 0, section: 0))
        footerAttributes.frame = CGRect(
            origin: .init(x: 0, y: collectionView!.bounds.maxY - footerHeight),
            size: .init(width: collectionView!.bounds.width, height: footerHeight)
        )
        cache.append(footerAttributes)
        for number in 0..<itemsCount {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: number, section: 0))
            var frame = CGRect.zero
            let internalCounter = number % 4
            switch internalCounter {
            case 0:
                frame.origin = .init(x: 0, y: yShift)
                frame.size = bigCellSize
            case 1:
                frame.origin = .init(x: bigCellSize.width + itemSpacing, y: yShift)
                frame.size = smallCellSize
                yShift += (bigCellSize.height + rowSpacing)
            case 2:
                frame.origin = .init(x: 0, y: yShift)
                frame.size = smallCellSize
            case 3:
                frame.origin = .init(x: smallCellSize.width + itemSpacing, y: yShift)
                frame.size = bigCellSize
                yShift += (bigCellSize.height + rowSpacing)
            default:
                fatalError("UB")
            }
            attributes.frame = frame
            cache.append(attributes)
        }
        if itemsCount != 0 {
            let lastAttributes = cache.last!
            collectionViewContentHeight = lastAttributes.frame.origin.y + lastAttributes.frame.height
        } else {
            collectionViewContentHeight = .zero
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { $0.frame.intersects(rect) }
    }
}
