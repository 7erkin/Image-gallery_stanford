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
        case initialized
        case removed(in: GalleryKind, at: Int)
        case added(in: GalleryKind, at: Int)
        case swapped(in: GalleryKind, firstIndex: Int, secondIndex: Int)
        case renamed(in: GalleryKind, at: Int)
    }
}

class GalleriesEditor: GalleryStorageObserver {
    private(set) var galleries: [GalleryStorage.Gallery]
    private(set) var recentlyDeletedGalleries: [GalleryStorage.Gallery] = []
    
    init() {
        GalleryStorage.shared.subscribe(self)
    }
        
    private var observers = [GalleriesEditorObserver]()
    
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
    
    func createGallery(withName name: String) {
        GalleryStorage.shared.createGallery(withName: name)
    }
    
    func moveToRecentlyDeleted(galleryByIndex index: Int) {
        let gallery = galleries.remove(at: index)
        recentlyDeletedGalleries.append(gallery)
    }
    
    func restoreGallery(at index: Int) {
        let gallery = recentlyDeletedGalleries.remove(at: index)
        galleries.append(gallery)
    }
    
    func removeGalleryPermanently(at index: Int) {
        GalleryStorage.shared.deleteGallery(by: galleries[index].id)
    }
    
    func renameGallery(gallerySection: GalleryKind, at index: Int, name: String) {
        if gallerySection == .actualImageGallery {
            galleries[index].name = name
        } else {
            recentlyDeletedGalleries[index].name = name
        }
    }
    
    func getGalleries() {
        GalleryStorage.shared.getGalleries({[weak self] galleries in
            self?.galleries = galleries
        })
    }
    
    // MARK: - GalleryStorageObserver impl
    func notify(with events: [GalleryStorage.Event]) {
        
    }
}
