//
//  Item.swift
//  iWallpaper
//
//  Created by yfm on 2024/1/5.
//

import Foundation

class Item: Codable {
    var id: String?
    var src640: String?
    var src1280: String?
    var downloadlink: String?
}

class SearchResult: Codable {
    var data: [SearchItem] = []
    
    func tranformToItems() -> [Item] {
        var result: [Item] = []
        for element in self.data {
            var item = Item()
            item.id = "\(element.attributes.id ?? 0)"
            item.src640 = element.attributes.image?.medium
            item.src1280 = element.attributes.image?.large
            item.downloadlink = element.attributes.image?.download_link
            result.append(item)
        }
        return result
    }
}

class SearchItem: Codable {
    var attributes: Attributes
}

class Attributes: Codable {
    var id: Int?
    var image: Image?
}

class Image: Codable {
    var medium: String?
    var large: String?
    var download_link: String?
}
