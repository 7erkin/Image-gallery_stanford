//
//  Storage.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 21/03/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

protocol GalleriesEditorObserver: class {
    func notify(with: [GalleriesEditor.Event])
}

extension GalleriesEditor {
    enum GalleryKind {
        case actualImageGallery
        case recentlyDeletedImageGallery
    }
    
    enum Event {
        case fetched
        case deleted(atIndex: Int)
        case deletedPermanently(atIndex: Int)
        case created(atIndex: Int)
        case swapped(in: GalleryKind, firstIndex: Int, secondIndex: Int)
        case renamed(in: GalleryKind, atIndex: Int)
        case restored(atIndex: Int)
    }
}

class GalleriesEditor {
    private(set) var galleries: [GalleryRamStorage.Gallery] = []
    private(set) var recentlyDeletedGalleries: [GalleryRamStorage.Gallery] = []
    
    // memory leak? Whether Observer deinit is called before?
    private var observers = [GalleriesEditorObserver]()
    
    unowned var storage = GalleryRamStorage.shared
    
    func subscribe(_ observer: GalleriesEditorObserver) {
        if observers.firstIndex(where: { $0 === observer }) == nil {
            observers.append(observer)
        }
    }
    
    func unsubscribe(_ observer: GalleriesEditorObserver) {
        if let index = observers.firstIndex(where: { $0 === observer }) {
            observers.remove(at: index)
        }
    }
    
    func notifyAll(with events: [Event]) {
        observers.forEach { $0.notify(with: events) }
    }
    
    func fetchGalleries() {
        storage.getGalleries {[weak self] galleries in
            self?.storage.getRecentlyDeletedGalleries({ recentlyDeletedGalleries in
                self?.galleries = galleries.orderedByIndexInCollection
                self?.recentlyDeletedGalleries = recentlyDeletedGalleries.orderedByIndexInCollection
                self?.notifyAll(with: [.fetched])
            })
        }
    }
    
    func createGallery(withName name: String, byIndex index: Int) {
        storage.create(gallery: .init(name: name, images: [], indexInCollection: index)) { [weak self] (created, gallery) in
            if created, let gallery = gallery {
                guard let self = self else { return }
                self.galleries = (self.galleries + [gallery]).orderedByIndexInCollection
                notifyAll(with: [.created(atIndex: index)])
            }
        }
    }
    
    func deleteGallery(byGalleryId id: Int) {
        storage.deleteGallery(byGalleryId: id) { [weak self] deleted in
            if deleted {
                guard let self = self else { return }
                let index = self.galleries.firstIndex(where: { $0.id == id })!
                self.galleries.remove(at: index)
                notifyAll(with: [.removed(at: index)])
            }
        }
    }
    
    func restoreGallery(byGalleryId id: Int) {
        storage.restoreGallery(byGalleryId: id) { [weak self] (restored, gallery) in
            if restored, let gallery = gallery, let self = self {
                let index = recentlyDeletedGalleries.firstIndex(where: { $0.id == gallery.id })!
                let insertionIndex = self.galleries.firstIndex(where: { $0.data.indexInCollection > gallery.data.indexInCollection })!
                self.galleries.insert(self.recentlyDeletedGalleries.remove(at: index), at: insertionIndex)
                notifyAll(with: [.restored(at: insertionIndex)])
            }
        }
    }
    
    func deleteGalleryPermanently(byGalleryId id: Int) {
        storage.deleteGalleryPermanently(byGalleryId: id) { [weak self] deleted in
            if deleted, let self = self {
                let index = self.recentlyDeletedGalleries.firstIndex(where: { $0.id == id })!
                self.recentlyDeletedGalleries.remove(at: index)
                notifyAll(with: [.deleted(at: index)])
            }
        }
    }
    
    func renameGallery(gallerySection: GalleryKind, byGalleryId id: Int, withName name: String) {
        storage.renameGallery(byGalleryId: id, withName: name) { [weak self] renamed in
            if renamed, let self = self {
                var index: Int!
                if gallerySection == .actualImageGallery {
                    index = self.galleries.firstIndex(where: { $0.id == id })!
                    galleries[index].data.name = name
                } else {
                    index = self.recentlyDeletedGalleries.firstIndex(where: { $0.id == id })!
                    recentlyDeletedGalleries[index].data.name = name
                }
                notifyAll(with: [.renamed(in: gallerySection, at: index)])
            }
        }
    }
    
    func swapGalleries() {}
}

extension Array where Element == GalleryRamStorage.Gallery {
    var orderedByIndexInCollection: [GalleryRamStorage.Gallery] {
        return self.sorted(by: { $0.data.indexInCollection > $1.data.indexInCollection })
    }
}
