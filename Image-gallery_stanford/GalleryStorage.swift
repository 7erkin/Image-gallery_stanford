//
//  ImageGalleryStorage.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 08/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

extension GalleryStorage {
    struct ImageData {
        var url: URL
        var aspectRatio: Float
        var indexInCollection: Int
    }
    
    struct Image {
        var id: Int
        var data: ImageData
    }
    
    struct GalleryData {
        var name: String
        var images: [Image]
        var indexInCollection: Int
    }
    
    struct Gallery {
        var id: Int
        var data: GalleryData
    }
}

class GalleryStorage {
    private var galleries: [Gallery] = [
        .init(id: 0, data: .init(name: "Gallery1", images: [], indexInCollection: 0)),
        .init(id: 1, data: .init(name: "Gallery2", images: [], indexInCollection: 1)),
        .init(id: 2, data: .init(name: "Gallery3", images: [], indexInCollection: 2))
    ]
    
    private var recentlyDeletedGalleries: [Gallery] = []
    
    static var shared = GalleryStorage()
    
    private init() {}
    
    // MARK: - GalleriesAPI
    func getGalleries(_ completion: ([Gallery]) -> Void) {
        completion(galleries)
    }
    
    func getRecentlyDeletedGalleries(_ completion: ([Gallery]) -> Void) {
        completion(recentlyDeletedGalleries)
    }
    
    func getGalleryBy(id: Int, _ completion: ((Gallery?) -> Void)) {
        completion(galleries.first(where: { $0.id == id }))
    }
    
    func restoreGallery(byGalleryId id: Int, _ completion: (Bool, Gallery?) -> Void) {}
    
    func create(gallery galleryData: GalleryData, _ completion: (Bool, Gallery?) -> Void) {
        
    }
    
    func deleteGallery(byGalleryId id: Int, _ completion: (Bool) -> Void) {
    }
    
    func deleteGalleryPermanently(byGalleryId id: Int, _ completion: (Bool) -> Void) {}
    
    func renameGallery(byGalleryId id: Int, withName name: String, _ completion: (Bool) -> Void) {}
    
    func swapGalleries(firstGalleryId: Int, secondGalleryId: Int, _ completion: (Bool) -> Void) {}
    
    // MARK: - ImagesAPI
    func create(image imageData: ImageData) {}
    
    func deleteImage(byImageId id: Int) {}
    
    func swapImages(firstImageId: Int, secondImageId: Int) {}
}
