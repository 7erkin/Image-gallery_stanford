//
//  URL+.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 15/03/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

extension URL {
    public var queryParameters: [String:String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
    public var imageURL: URL? {
        guard
            let queryParameters = self.queryParameters,
            let urlStr = queryParameters["imgurl"],
            let imgUrl = URL(string: urlStr)
        else {
                return nil
        }
        return imgUrl
    }
}
