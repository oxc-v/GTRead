//
//  GTSearchHistoryDataModel.swift
//  GTRead
//
//  Created by Dev on 2021/11/20.
//

import Foundation
import UIKit

struct GTSearchHistoryDataModel: Codable {
    var lists: [GTSearchHistoryDataModelItem]?
    var count: Int = -1
    
    enum CodingKeys: String, CodingKey {
        case lists
        case count
    }
}

struct GTSearchHistoryDataModelItem: Codable {
    var searchText: String
    
    enum CodingKeys: String, CodingKey {
        case searchText
    }
}
