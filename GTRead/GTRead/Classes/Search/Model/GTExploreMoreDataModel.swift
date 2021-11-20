//
//  GTExploreMoreDataModel.swift
//  GTRead
//
//  Created by Dev on 2021/11/19.
//

import Foundation
import UIKit

struct GTExploreMoreDataModel: Codable {
    var lists: [GTBookDataModel]?
    var count: Int
    
    enum CodingKeys: String, CodingKey {
        case lists
        case count
    }
}
