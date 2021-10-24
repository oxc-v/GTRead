//
//  GTPdfDataModel.swift
//  GTRead
//
//  Created by Dev on 2021/10/24.
//

import UIKit

struct GTPdfDataModel: Codable{
    var userId: String?
    var bookId: String?
    var page: Int?
    var Url: String?
    var code: Int
    enum CodingKeys: String, CodingKey {
        case userId
        case bookId
        case page
        case Url
        case code
    }
}
