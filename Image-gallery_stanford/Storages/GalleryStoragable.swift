//
//  GalleryStoragable.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 10/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

enum Rating {
    case none
    case veryLow
    case low
    case middle
    case high
    case veryHigh
}

struct ImageData {
    var url: URL
    var rating: Rating
    var dateOfCreate: Date
    var indexInCollection: Int
}

struct Image {
    var id: Int
    var data: ImageData
}

struct GalleryData {
    var name: String
    var images: [Image]
}

struct Gallery {
    var id: Int
    var data: GalleryData
}

protocol GalleryStoragable: class {
    static var shared: GalleryStoragable { get }
    // GalleriesAPI
    func getGalleries(_ completion: ([Gallery]) -> Void)
    func getGallery(byId id: Int, _ completion: (Gallery?) -> Void)
    func getRecentlyDeletedGalleries(_ completion: ([Gallery]) -> Void)
    func restoreGallery(byId id: Int, _ completion: (Bool) -> Void)
    func deleteGallery(byId id: Int, _ completion: (Bool, [Gallery]?) -> Void)
    func deleteGalleryPermanently(byId id: Int, _ completion: (Bool, [Gallery]?) -> Void)
    func createGallery(withName name: String, _ completion: (Bool, [Gallery]?) -> Void)
    func renameGallery(byId id: Int, withName name: String, _ completion: (Bool, Gallery?) -> Void)
    func moveGallery(byId movedGalleryId: Int, onPlaceWhereGalleryWithId takingPlaceGalleryId: Int, _ completion: (Bool) -> Void)
    // ImagesAPI
    func createImage(_ imageData: ImageData, inGalleryId galleryId: Int, onPlaceWhereImageWithId id: Int, _ completion: (Bool, [Image]?) -> Void)
    func deleteImage(byId id: Int, inGalleryId galleryId: Int, _ completion: (Bool, [Image]?) -> Void)
    func moveImage(byId movedImageId: Int, inGalleryId galleryId: Int, onPlaceWhereImageWithId takingPlaceImageId: Int, _ completion: (Bool, [Image]?) -> Void)
}
