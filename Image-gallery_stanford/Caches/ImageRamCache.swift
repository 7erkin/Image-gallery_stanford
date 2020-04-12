//
//  ImageRamCache.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 12/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

//class LockGuard {
//    // correct?
//    private var _m: pthread_mutex_t
//    init(_ m: pthread_mutex_t) {
//        self._m = m
//        pthread_mutex_lock(&_m)
//    }
//    deinit {
//        unlock()
//    }
//    func unlock() {
//        pthread_mutex_unlock(&_m)
//    }
//}

class ImageRamCache: ImageCachable {
    private var cache: [URL:UIImage] = [:]
    private var m: pthread_mutex_t = pthread_mutex_t()
    
    private init() {}
    static var shared: ImageCachable = ImageRamCache()
    
    func hasImage(byUrl url: URL, _ completion: @escaping (Bool) -> Void) {
        pthread_mutex_lock(&m)
        let index = cache.index(forKey: url)
        pthread_mutex_unlock(&m)
        completion(index != nil)
    }
    
    func getImage(byUrl url: URL, _ completion: @escaping (UIImage?) -> Void) {
        pthread_mutex_lock(&m)
        let image = cache[url]
        pthread_mutex_unlock(&m)
        completion(image)
    }
    
    func saveImage(byUrl url: URL, _ image: UIImage) {
        pthread_mutex_lock(&m)
        cache[url] = image
        pthread_mutex_unlock(&m)
    }
}
