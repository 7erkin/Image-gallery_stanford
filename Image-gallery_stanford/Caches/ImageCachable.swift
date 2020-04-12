//
//  ImageCachable.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 12/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

protocol ImageCachable {
    static var shared: ImageCachable { get }
    func hasImage(byUrl url: URL, _ completion: @escaping (Bool) -> Void)
    func getImage(byUrl url: URL, _ completion: @escaping (UIImage?) -> Void)
    func saveImage(byUrl url: URL, _ image: UIImage)
}
