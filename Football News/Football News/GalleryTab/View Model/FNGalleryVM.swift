//
//  FNGalleryVM.swift
//  Football News
//
//  Created by Mahnoor Khan on 23/07/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import Foundation

class FNGalleryVM {
    // MARK: Properties
    var model       :   [GalleryObject]?
    var itemCount   :   Int {
        get {
            return model?.count ?? 0
        }
    }
    
    // MARK: Initializer
    init() {
        getGallery()
    }
}

// MARK: Functions
extension FNGalleryVM {
    func itemAt(_ indexPath: IndexPath) -> GalleryObject? {
        guard let _model = model, itemCount > 0 else { return nil }
        return _model[indexPath.row]
    }
}

// MARK: Fetching Objects
extension FNGalleryVM : GalleryService {
    func getGallery() {
        fetchGallery { (objects) in
            if let fetchedObjects : [GalleryObject] = objects {
                self.model = fetchedObjects
            }
            else {
                
            }
        }
    }
}
