//
//  GTCustomPlainTableViewCellDataModel.swift
//  GTRead
//
//  Created by Dev on 2021/11/21.
//

import Foundation
import UIKit

struct GTCustomPlainTableViewCellDataModel: Codable {
    var lists: [GTCustomPlainTableViewCellDataModelItem]?
    var count: Int
    
    enum CodingKeys: String, CodingKey {
        case lists
        case count
    }
}

struct GTCustomPlainTableViewCellDataModelItem: Codable {
    var imgName: String
    var titleText: String
    
    enum CodingKeys: String, CodingKey {
        case imgName
        case titleText
    }
}
