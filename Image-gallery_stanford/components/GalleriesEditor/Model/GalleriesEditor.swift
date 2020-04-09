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
        case galleriesFetched
        case galleryDeleted(fromIndex: Int, toIndex: Int)
        case galleryDeletedPermanently(byIndex: Int)
        case galleryCreated(byIndex: Int)
        case galleryRenamed(in: GalleryKind, byIndex: Int)
        case galleryRestored(byIndex: Int, fromIndex: Int)
    }
}

func firstDifferentElementIndex(lhs: [Gallery], rhs: [Gallery], where predicate: (Gallery, Gallery) -> Bool) -> Int? {
    let iterableGalleries = lhs.count > rhs.count ? rhs : lhs
    for index in iterableGalleries.indices {
        if predicate(lhs[index], rhs[index]) {
            return index
        }
    }
    if rhs.count != lhs.count {
        return lhs.count > rhs.count ? rhs.count : lhs.count
    }
    return nil
}

class GalleriesEditor {
    private(set) var galleries: [Gallery] = []
    private(set) var recentlyDeletedGalleries: [Gallery] = []
    
    // any memory leak?
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
        storage.getGalleries { [weak self] galleries in
            self?.storage.getRecentlyDeletedGalleries { recentlyDeletedGalleries in
                self?.galleries = galleries
                self?.recentlyDeletedGalleries = recentlyDeletedGalleries
                self?.notifyAll(with: [.galleriesFetched])
            }
        }
    }
    
    func createGallery(withName name: String) {
        storage.createGallery(withName: name) { [weak self] (res, galleries) in
            if res, let galleries = galleries, let self = self {
                for (index, gallery) in self.galleries.enumerated() {
                    if gallery.id != galleries[index].id {
                        self.galleries = galleries
                        notifyAll(with: [.galleryCreated(byIndex: index)])
                        return
                    }
                }
                self.galleries = galleries
                notifyAll(with: [.galleryCreated(byIndex: galleries.count - 1)])
            }
        }
    }
    
    func deleteGallery(byGalleryId id: Int) {
        storage.deleteGallery(byId: id) { [weak self] (res, galleries) in
            if res {
                self?.storage.getRecentlyDeletedGalleries { recentlyDeletedGalleries in
                    if let self = self, let galleries = galleries {
                        let predicate: (Gallery, Gallery) -> Bool = { $0.id != $1.id }
                        let deletingIndex = firstDifferentElementIndex(lhs: self.galleries, rhs: galleries, where: predicate)!
                        let insertingIndex = firstDifferentElementIndex(lhs: self.recentlyDeletedGalleries, rhs: recentlyDeletedGalleries, where: predicate) ?? recentlyDeletedGalleries.lastIndex!
                        self.galleries = galleries
                        self.recentlyDeletedGalleries = recentlyDeletedGalleries
                        notifyAll(with: [.galleryDeleted(fromIndex: deletingIndex, toIndex: insertingIndex)])
                    }
                }
            }
        }
    }
    
    func restoreGallery(byGalleryId id: Int) {
        storage.restoreGallery(byId: id) { [weak self] (res) in
            if res {
                self?.storage.getGalleries { galleries in
                    self?.storage.getRecentlyDeletedGalleries { recentlyDeletedGalleries in
                        if let self = self {
                            let predicate: (Gallery, Gallery) -> Bool = { $0.id != $1.id }
                            let insertionIndex = firstDifferentElementIndex(lhs: self.galleries, rhs: galleries, where: predicate)!
                            let deletingIndex = firstDifferentElementIndex(lhs: self.recentlyDeletedGalleries, rhs: recentlyDeletedGalleries, where: predicate)!
                            self.galleries = galleries
                            self.recentlyDeletedGalleries = recentlyDeletedGalleries
                            notifyAll(with: [.galleryRestored(byIndex: insertionIndex, fromIndex: deletingIndex)])
                        }
                    }
                }
            }
        }
    }
    
    func deleteGalleryPermanently(byGalleryId id: Int) {
        storage.deleteGalleryPermanently(byId: id) { [weak self] (res, recentlyDeletedGalleries) in
            if res, let recentlyDeletedGalleries = recentlyDeletedGalleries {
                for (index, gallery) in galleries.enumerated() {
                    if gallery.id != self?.recentlyDeletedGalleries[index].id {
                        self?.recentlyDeletedGalleries = recentlyDeletedGalleries
                        notifyAll(with: [.galleryDeletedPermanently(byIndex: index)])
                    }
                }
            }
        }
    }
    
    func renameGallery(byGalleryId id: Int, withName name: String) {
        storage.renameGallery(byId: id, withName: name) { [weak self] res in
            if res, let self = self {
            }
        }
    }
}
