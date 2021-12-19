//
//  GTSearchBookDataModel.swift
//  GTRead
//
//  Created by Dev on 2021/12/1.
//

import Foundation
import UIKit

struct GTSearchBookDataModel: Codable {
    var lists: [GTBookDataModel]?
    var count: Int
    
    enum CodingKeys: String, CodingKey {
        case lists
        case count
    }
}
