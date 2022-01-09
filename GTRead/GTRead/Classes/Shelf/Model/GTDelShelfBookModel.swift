//
//  GTDelShelfBookModel.swift
//  GTRead
//
//  Created by Dev on 2021/10/31.
//

import UIKit

struct GTDelShelfBookModel: Codable {
    var userId: Int
    var susCount: Int
    var FailBookIds: [String]?
    
    enum CodingKeys: String, CodingKey {
        case userId
        case susCount
        case FailBookIds
    }
}
