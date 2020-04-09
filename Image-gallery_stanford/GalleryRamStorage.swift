//
//  ImageGalleryStorage.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 08/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

class Identifier {
    private static var identifier: Int = 0
    static func get() -> Int {
        defer { identifier += 1 }
        return identifier
    }
}

class GalleryIdentifier: Identifier {}
class ImageIdentifier: Identifier {}

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
    func renameGallery(byId id: Int, withName name: String, _ completion: (Bool) -> Void)
    func moveGallery(byId movedGalleryId: Int, onPlaceWhereGalleryWithId takingPlaceGalleryId: Int, _ completion: (Bool) -> Void)
    // ImagesAPI
    func createImage(_ imageData: ImageData, inGalleryId galleryId: Int, onPlaceWhereImageWithId id: Int, _ completion: (Bool, [Image]?) -> Void)
    func deleteImage(byId id: Int, inGalleryId galleryId: Int, _ completion: (Bool, [Image]?) -> Void)
    func moveImage(byId movedImageId: Int, inGalleryId galleryId: Int, onPlaceWhereImageWithId takingPlaceImageId: Int, _ completion: (Bool, [Image]?) -> Void)
}

class GalleryRamStorage: GalleryStoragable {
    private var galleries: [Gallery] = []
    
    private var recentlyDeletedGalleries: [Gallery] = []
    
    private static var _instance = GalleryRamStorage()
    
    private init() {}

    // MARK: - GalleryStoragable
    static var shared: GalleryStoragable {
        return _instance
    }

    func createGallery(withName name: String, _ completion: (Bool, [Gallery]?) -> Void) {
        if galleries.first(where: { $0.data.name == name }) == nil {
            let gallery = Gallery(id: Identifier.get(), data: .init(name: name, images: []))
            galleries.insert(gallery, at: 0)
            completion(true, galleries)
            return
        }
        completion(false, nil)
    }
    
    func restoreGallery(byId id: Int, _ completion: (Bool) -> Void) {
        if let index = recentlyDeletedGalleries.firstIndex(where: { $0.id == id }) {
            let gallery = recentlyDeletedGalleries.remove(at: index)
            galleries.append(gallery)
            completion(true)
            return
        }
        completion(false)
    }
    
    func deleteGallery(byId id: Int, _ completion: (Bool, [Gallery]?) -> Void) {
        if let index = galleries.firstIndex(where: { $0.id == id }) {
            let gallery = galleries.remove(at: index)
            recentlyDeletedGalleries.append(gallery)
            completion(true, galleries)
            return
        }
        completion(false, nil)
    }
    
    func deleteGalleryPermanently(byId id: Int, _ completion: (Bool, [Gallery]?) -> Void) {
        if let index = recentlyDeletedGalleries.firstIndex(where: { $0.id == id }) {
            recentlyDeletedGalleries.remove(at: index)
            completion(true, recentlyDeletedGalleries)
            return
        }
        completion(false, nil)
    }
    
    func renameGallery(byId id: Int, withName name: String, _ completion: (Bool) -> Void) {
        if let index = galleries.firstIndex(where: { $0.id == id }) {
            galleries[index].data.name = name
        } else {
            if let index = recentlyDeletedGalleries.firstIndex(where: { $0.id == id }) {
                recentlyDeletedGalleries[index].data.name = name
            } else {
                completion(false)
                return
            }
        }
        completion(true)
    }
    
    func moveGallery(byId movedGalleryId: Int, onPlaceWhereGalleryWithId takingPlaceGalleryId: Int, _ completion: (Bool) -> Void) {
        if
            let indexMovedGallery = galleries.firstIndex(where: { $0.id == movedGalleryId }),
            let indexTakingPlaceGallery = galleries.firstIndex(where: { $0.id == takingPlaceGalleryId }) {
            let gallery = galleries.remove(at: indexMovedGallery)
            galleries.insert(gallery, at: indexTakingPlaceGallery)
        } else {
            if
                let indexMovedGallery = galleries.firstIndex(where: { $0.id == movedGalleryId }),
                let indexTakingPlaceGallery = galleries.firstIndex(where: { $0.id == takingPlaceGalleryId }) {
                let gallery = recentlyDeletedGalleries.remove(at: indexMovedGallery)
                recentlyDeletedGalleries.insert(gallery, at: indexTakingPlaceGallery)
            } else {
                completion(false)
                return
            }
        }
        completion(true)
    }
    
    func createImage(_ imageData: ImageData, inGalleryId galleryId: Int, onPlaceWhereImageWithId takingPlaceImageId: Int, _ completion: (Bool, [Image]?) -> Void) {
        if let index = galleries.firstIndex(where: { $0.id == galleryId }) {
            let image = Image(id: ImageIdentifier.get(), data: imageData)
            let insertionIndex = galleries[index].data.images.firstIndex(where: { $0.id == takingPlaceImageId })!
            galleries[index].data.images.insert(image, at: insertionIndex)
            completion(true, galleries[index].data.images)
            return
        }
        completion(false, nil)
    }
    
    func deleteImage(byId id: Int, inGalleryId galleryId: Int, _ completion: (Bool, [Image]?) -> Void) {
        if let index = galleries.firstIndex(where: { $0.id == galleryId }) {
            let imageIndex = galleries[index].data.images.firstIndex(where: { $0.id == id })!
            galleries[index].data.images.remove(at: imageIndex)
            completion(true, galleries[index].data.images)
            return
        }
        completion(false, nil)
    }
    
    func moveImage(byId movedImageId: Int, inGalleryId galleryId: Int, onPlaceWhereImageWithId takingPlaceImageId: Int, _ completion: (Bool, [Image]?) -> Void) {
        if
            let indexGallery = galleries.firstIndex(where: { $0.id == galleryId }),
            let indexMovedImage = galleries[indexGallery].data.images.firstIndex(where: { $0.id == movedImageId }),
            let indexTakingPlaceImage = galleries[indexGallery].data.images.firstIndex(where: { $0.id == takingPlaceImageId }) {
            var images = galleries[indexGallery].data.images
            let image = images.remove(at: indexMovedImage)
            images.insert(image, at: indexTakingPlaceImage)
            galleries[indexGallery].data.images = images
            completion(true, images)
            return
        }
        completion(false, nil)
    }
    
    func getGalleries(_ completion: ([Gallery]) -> Void) {
        completion(galleries)
    }
    
    func getGallery(byId id: Int, _ completion: (Gallery?) -> Void) {
        if let gallery = galleries.first(where: { $0.id == id }) {
            completion(gallery)
        } else {
            if let gallery = recentlyDeletedGalleries.first(where: { $0.id == id }) {
                completion(gallery)
            } else {
                completion(nil)
            }
        }
    }
    
    func getRecentlyDeletedGalleries(_ completion: ([Gallery]) -> Void) {
        completion(recentlyDeletedGalleries)
    }
}

 
