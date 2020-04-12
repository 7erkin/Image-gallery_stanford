//
//  ImageGallery.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 22/03/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

protocol GalleryPresenterObserver: class {
    func notify(with: [GalleryPresenter.Event])
}

class GalleryPresenter {
    enum Event {
        case galleryFetched
        case imageAdded(byIndex: Int)
        case imagesDeleted(byIndices: [Int])
        case imageMoved(firstIndex: Int, secondIndex: Int)
        case galleryNameUpdated
    }
    
    private unowned var storage = AppContext.galleryStorage
    var galleryId: Int!
    private(set) var gallery: Gallery!
    private var observers = [GalleryPresenterObserver]()
    
    func subscribe(_ observer: GalleryPresenterObserver) {
        if observers.firstIndex(where: { $0 === observer }) == nil {
            observers.append(observer)
        }
    }
    
    func unsubscribe(_ observer: GalleryPresenterObserver) {
        if let index = observers.firstIndex(where: { $0 === observer }) {
            observers.remove(at: index)
        }
    }
    
    func notifyAll(with events: [Event]) {
        observers.forEach { $0.notify(with: events) }
    }
    
    func fetchGallery() {
        storage.getGallery(byId: galleryId) { gallery in
            if let gallery = gallery {
                self.gallery = gallery
                notifyAll(with: [.galleryFetched])
            }
        }
    }
    
    func moveImage(byIndex indexFrom: Int, toIndex indexTo: Int) {
        storage.moveImage(
            byId: gallery.data.images[indexFrom].id,
            inGalleryId: galleryId,
            onPlaceWhereImageWithId: gallery.data.images[indexTo].id) { [weak self] (res, images) in
                if res, let images = images, let self = self {
                    self.gallery.data.images = images
                    self.notifyAll(with: [.imageMoved(firstIndex: indexFrom, secondIndex: indexTo)])
                }
        }
    }
    
    func addImage(byIndex index: Int, withUrl url: URL) {
        storage.createImage(
            NewImage(url: url),
            inGalleryId: galleryId,
            onPlaceWhereImageWithId: gallery.data.images[index].id) { (res, images) in
                if res, let images = images {
                    gallery.data.images = images
                    notifyAll(with: [.imageAdded(byIndex: index)])
                }
        }
    }
    
    func deleteImages(byIndices indices: [Int]) {
        storage.deleteImages(byIds: indices.map { gallery.data.images[$0].id }, inGalleryId: galleryId) { [weak self] (res, images) in
            if res, let images = images, let self = self {
                self.gallery.data.images = images
                self.notifyAll(with: [.imagesDeleted(byIndices: indices)])
            }
        }
    }
}
