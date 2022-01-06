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
