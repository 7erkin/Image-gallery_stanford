//
//  AppContext.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 10/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

class AppContext {
    static var galleryStorage: GalleryStoragable = GalleryRamStorage.shared
    static var imageCache: ImageCachable = ImageRamCache.shared
}
