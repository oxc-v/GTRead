//
//  GTBookStoreADBookDataModel.swift
//  GTRead
//
//  Created by Dev on 2021/11/12.
//

import Foundation
import UIKit

struct GTBookStoreADBookDataModel: Codable {
    var lists: [GTBookDataModel]?
    var count: Int
    
    enum CodingKeys: String, CodingKey {
        case lists
        case count
    }
}
