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

class GalleryRamStorage: GalleryStoragable {
    private var galleries: [Gallery] = [
        Gallery(id: 0, data: GalleryData(
            name: "Fallout",
            images: [
                "https://u.kanobu.ru/editor/images/80/eb8e4568-6042-4129-9f8d-47be57bfb061.jpg",
                "https://games.mail.ru/pre_1280x720_resize/hotbox/content_files/gallery/a5/d7/45b034b6.jpeg?quality=85",
                "https://www.1c-interes.ru/upload/resize_src/e7/e7e8c698db3c12b2421a31a946ce76c5.jpg",
                "https://www.ferra.ru/thumb/625x0/filters:quality(75)/imgs/2018/11/26/19/2801712/0891c67eb3e5e6ec569a1c51fd93b45538764465.jpg"
                ].enumerated().map { idx, el in Image(id: idx, data: ImageData(url: URL(string: el)!, rating: .high, dateOfCreate: .distantPast, indexInCollection: idx)) }
        ))
    ]
    
    private var recentlyDeletedGalleries: [Gallery] = []
    
    private init() {}

    // MARK: - GalleryStoragable
    static var shared: GalleryStoragable = GalleryRamStorage()

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
    
    func renameGallery(byId id: Int, withName name: String, _ completion: (Bool, Gallery?) -> Void) {
        if let index = galleries.firstIndex(where: { $0.id == id }) {
            galleries[index].data.name = name
            completion(true, galleries[index])
        } else {
            if let index = recentlyDeletedGalleries.firstIndex(where: { $0.id == id }) {
                recentlyDeletedGalleries[index].data.name = name
                completion(true, recentlyDeletedGalleries[index])
            } else {
                completion(false, nil)
                return
            }
        }
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
    
    func createImage(_ image: NewImage, inGalleryId galleryId: Int, onPlaceWhereImageWithId takingPlaceImageId: Int, _ completion: (Bool, [Image]?) -> Void) {
        if let index = galleries.firstIndex(where: { $0.id == galleryId }) {
            let image = Image(id: ImageIdentifier.get(), data: ImageData(url: image.url, rating: .veryLow, dateOfCreate: .distantPast, indexInCollection: 0))
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
    
    func deleteImages(byIds ids: [Int], inGalleryId galleryId: Int, _ completion: (Bool, [Image]?) -> Void) {
        if let galleryIndex = galleries.firstIndex(where: { $0.id == galleryId }) {
            let images = galleries[galleryIndex].data.images.enumerated().filter { (idx, _) in !ids.contains(idx) }.map { $1 }
            galleries[galleryIndex].data.images = images
            completion(true, images)
        }
        completion(false, nil)
    }
}

 
