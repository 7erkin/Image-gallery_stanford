//
//  UIImage+.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 25/03/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    var aspectRatio: Float {
        return Float(size.height / size.width)
    }
}
