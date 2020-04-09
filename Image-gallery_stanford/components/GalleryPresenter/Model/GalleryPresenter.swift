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

class GalleryPresenter: GalleryStorageObserver {
    enum Event {
        case imageAdded(byIndex: Int)
        case imagesDeleted(byIndices: [Int])
        case imagesSwaped(firstIndex: Int, secondIndex: Int)
        case galleryRenamed
        case uploaded
    }
    
    private var galleryId: Int
    
    private(set) var gallery: GalleryRamStorage.Gallery!
    
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
    
    init(withGalleryId id: Int) {
        galleryId = id
    }
    
    deinit {
        GalleryRamStorage.shared.unsubscribe(self)
    }
    
    func upload() {
        GalleryRamStorage.shared.getGalleryBy(id: galleryId) {[weak self] gallery in
            guard let self = self else { return }
            guard let gallery = gallery else { fatalError("Unexpected behaviour") }
            self.gallery = gallery
            GalleryRamStorage.shared.subscribe(self)
            notifyAll(with: [.uploaded])
        }
    }
    
    func add(_ image: GalleryRamStorage.Image, at index: Int) {
    }
    
    // MARK: - GalleryStorageObserver impl
    func notify(with events: [GalleryRamStorage.Event]) {
        for event in events {
            switch event {
            case .galleryRenamed(let id):
                if gallery.id == id {
                    GalleryRamStorage.shared.getGalleryBy(id: id) { [weak self] gallery in
                        guard let gallery = gallery else { fatalError() }
                        self?.gallery.name = gallery.name
                        notifyAll(with: [.galleryRenamed])
                    }
                }
            default:
                break
            }
        }
    }
}
