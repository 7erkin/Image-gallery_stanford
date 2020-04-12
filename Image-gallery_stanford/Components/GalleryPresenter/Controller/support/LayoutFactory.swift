//
//  LayoutFactory.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 12/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import Foundation

class LayoutFactory {
    private static var counter = 0
    static func createNextLayout() -> UICollectionViewLayout {
        defer {
            counter += 1
            counter = counter % 2
        }
        switch counter {
        case 0:
            return TwoDifferentCellInRowLayout()
        case 1:
            return StretchedLayout()
        default:
            fatalError("UB")
        }
    }
}
