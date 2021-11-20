//
//  GTBookDataModel.swift
//  GTRead
//
//  Created by Dev on 2021/11/18.
//

import Foundation
import UIKit

struct GTBookDataModel: Codable {
    var bookId: String
    var bookName: String
    var bookHeadUrl: String
    var bookDownUrl: String
    var bookType: String
    var authorName: String
    var bookIntro: String
    var publishTime: String?
    enum CodingKeys: String, CodingKey {
        case bookId
        case bookName
        case bookHeadUrl
        case bookDownUrl
        case bookType
        case authorName
        case bookIntro
        case publishTime
    }
}
