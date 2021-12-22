//
//  GTShelfBookModel.swift
//  GTRead
//
//  Created by Dev on 2021/10/11.
//

import UIKit

struct GTShelfDataModel: Codable {
    var lists: [GTBookDataModel]?
    var count: Int
    enum CodingKeys: String, CodingKey {
        case lists
        case count
    }
}

//struct GTShelfDataModelItem: Codable{
//    var bookId: String
//    var bookName: String
//    var bookHeadUrl: String
//    var bookDownUrl: String
//    var bookType: String
//    var authorName: String
//
//    enum CodingKeys: String, CodingKey {
//        case bookId
//        case bookName
//        case bookHeadUrl
//        case bookDownUrl
//        case bookType
//        case authorName
//    }
//}

// 全局书库对象
//var GTCommonShelfDataModel: GTShelfDataModel?
