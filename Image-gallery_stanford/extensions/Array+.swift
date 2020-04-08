//
//  Array+.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 08/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

extension Array where Element == String {
    func makeUnique(newName: String) -> String {
        var name = newName
        for i in self.indices {
            if !self.contains(name) {
                return name
            }
            name = "\(newName) \(i)"
        }
        return "\(newName) \(self.indices.count + 1)"
    }
}

extension Array {
    var lastIndex: Int? {
        return self.isEmpty ? nil : self.count - 1
    }
}
