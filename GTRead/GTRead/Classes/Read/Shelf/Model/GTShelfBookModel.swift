//
//  GTShelfBookModel.swift
//  GTRead
//
//  Created by Dev on 2021/10/11.
//

import UIKit

struct GTShelfBookModel: Codable {
    var lists: [GTShelfBookItemModel]?
    var count: Int
    enum CodingKeys: String, CodingKey {
        case lists
        case count
    }
}

struct GTShelfBookItemModel: Codable{
    var bookId: String
    var bookName: String
    var bookHeadUrl: String
    var bookDownUrl: String
    var bookType: String
    var authorName: String
    
    enum CodingKeys: String, CodingKey {
        case bookId
        case bookName
        case bookHeadUrl
        case bookDownUrl
        case bookType
        case authorName
    }
}
