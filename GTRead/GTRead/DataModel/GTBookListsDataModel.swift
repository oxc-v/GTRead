//
//  GTBookListsDataModel.swift
//  GTRead
//
//  Created by Dev on 2022/2/24.
//

import Foundation
import UIKit

struct GTBookListsDataModel: Codable {
    var lists: [GTBookDataModel]?
    var count: Int
    
    enum CodingKeys: String, CodingKey {
        case lists
        case count
    }
}
