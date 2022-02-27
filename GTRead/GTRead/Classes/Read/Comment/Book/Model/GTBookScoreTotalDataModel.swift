//
//  GTBookScoreTotalDataModel.swift
//  GTRead
//
//  Created by Dev on 2022/2/27.
//

import Foundation

struct GTBookScoreTotalDataModel: Codable {
    
    var lists: [GTBookScoreTotalItem]?
    var status: GTErrorMessage
    
    enum CodingKeys: String, CodingKey {
        case lists
        case status
    }
}

struct GTBookScoreTotalItem: Codable {
    
    var score: Float
    var count: Int
    
    enum CodingKeys: String, CodingKey {
        case score
        case count
    }
}
