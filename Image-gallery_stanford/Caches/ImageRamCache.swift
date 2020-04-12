//
//  ImageRamCache.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 12/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

class LockGuard {
    private var _m: pthread_mutex_t
    init(_ m: pthread_mutex_t) {
        self._m = m
        pthread_mutex_lock(&_m)
    }
    deinit {
        unlock()
    }
    func unlock() {
        pthread_mutex_unlock(&_m)
    }
}

class ImageRamCache: ImageCachable {
    private var cache: [URL:UIImage] = [:]
    private var m: pthread_mutex_t = pthread_mutex_t()
    
    private init() {}
    static var shared: ImageCachable = ImageRamCache()
    
    func hasImage(byUrl url: URL, _ completion: @escaping (Bool) -> Void) {
        let lockGuard = LockGuard(m)
        let index = cache.index(forKey: url)
        lockGuard.unlock()
        completion(index != nil)
    }
    
    func getImage(byUrl url: URL, _ completion: @escaping (UIImage?) -> Void) {
        let lockGuard = LockGuard(m)
        let image = cache[url]
        lockGuard.unlock()
        completion(image)
    }
    
    func saveImage(byUrl url: URL, _ image: UIImage) {
        // because _ is not proper behaviour
        let lock = LockGuard(m)
        cache[url] = image
        lock.unlock()
    }
}
