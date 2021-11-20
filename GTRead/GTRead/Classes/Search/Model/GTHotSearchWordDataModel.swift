//
//  GTHotSearchWordDataModel.swift
//  GTRead
//
//  Created by Dev on 2021/11/19.
//

import Foundation
import UIKit

struct GTHotSearchWordDataModel: Codable {
    var lists: [GTHotSearchWordDataModelItem]?
    var count: Int
}

struct GTHotSearchWordDataModelItem: Codable {
    var bookId: String
    var bookName: String
    var searchTimes: Int
    
    enum CodingKeys: String, CodingKey {
        case bookId
        case bookName
        case searchTimes
    }
}
