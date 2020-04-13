//
//  NoCache.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 13/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

class NoCache: ImageCachable {
    static var shared: ImageCachable = NoCache()
    
    func hasImage(byUrl url: URL, _ completion: @escaping (Bool) -> Void) {
        completion(false)
    }
    
    func getImage(byUrl url: URL, _ completion: @escaping (UIImage?) -> Void) {
        completion(nil)
    }
    
    func saveImage(byUrl url: URL, _ image: UIImage) {}
}
