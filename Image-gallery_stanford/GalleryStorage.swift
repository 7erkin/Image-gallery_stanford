//
//  ImageGalleryStorage.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 08/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

protocol GalleryStorageObserver: class {
    func notify(with events: [GalleryStorage.Event])
}

extension GalleryStorage {
    struct Image {
        var url: URL
        var aspectRatio: Float
    }
    
    struct Gallery {
        var id: Int
        var name: String
        var images: [Image]
    }
}

class GalleryStorage {
    enum Event {
        case galleryRemoved(id: Int)
        case galleryCreated(id: Int)
        case galleryRenamed(id: Int)
    }
    
    var observers = [GalleryStorageObserver]()
    
    func subscribe(_ observer: GalleryStorageObserver) {
        if observers.firstIndex(where: { $0 === observer }) == nil {
            observers.append(observer)
        }
    }
    
    func unsubscribe(_ observer: GalleryStorageObserver) {
        if let index = observers.firstIndex(where: { $0 === observer }) {
            observers.remove(at: index)
        }
    }
    
    func notifyAll(with events: [Event]) {
        observers.forEach { $0.notify(with: events) }
    }
    
    private var galleries: [Gallery] = [
        .init(id: 0, name: "Gallery1", images: []),
        .init(id: 1, name: "Gallery2", images: []),
        .init(id: 2, name: "Gallery3", images: [])
    ]
    
    static var shared = GalleryStorage()
    
    private init() {}
    
    func getGalleries(_ completion: ([Gallery]) -> Void) {
        completion(galleries)
    }
    
    func getGalleryBy(id: Int, _ completion: ((Gallery?) -> Void)) {
        completion(galleries.first(where: { $0.id == id }))
    }
    
    func createGallery(withName name: String) {
        let id = galleries.count
        galleries.append(.init(id: id, name: name, images: []))
        notifyAll(with: [.galleryCreated(id: id)])
    }
    
    func deleteGallery(by id: Int) {
        if let index = galleries.firstIndex(where: { $0.id == id }) {
            notifyAll(with: [.galleryRemoved(id: index)])
        }
    }
    
    func updateGallery(_ gallery: Gallery) {
        if let index = galleries.firstIndex(where: { $0.id == gallery.id }) {
            galleries[index] = gallery
            notifyAll(with: [.galleryRenamed(id: gallery.id)])
        }
    }
}
