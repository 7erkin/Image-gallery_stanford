//
//  fetchImage.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 12/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

struct Utils {
    static func fetchImageFromCache(byUrl url: URL, _ completion: @escaping (Bool, UIImage?) -> Void) {
        let cache = AppContext.imageCache
        cache.hasImage(byUrl: url) { hasImage in
            if hasImage {
                cache.getImage(byUrl: url) { image in
                    guard let image = image else { fatalError("Undefined behaviour") }
                    
                    completion(true, image)
                }
            } else {
                completion(false, nil)
            }
        }
    }
    
    static func fetchImage(byUrl url: URL, _ completion: @escaping (Bool, UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            fetchImageFromCache(byUrl: url) { (result, image) in
                if result, let image = image {
                    completion(result, image)
                    return
                }
                
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        AppContext.imageCache.saveImage(byUrl: url, image)
                        completion(true, image)
                        return
                    }
                }
                completion(false, nil)
            }
        }
    }
}

