//
//  GTBookStoreADBookDataModel.swift
//  GTRead
//
//  Created by Dev on 2021/11/12.
//

import Foundation
import UIKit

struct GTBookStoreADBookDataModel: Codable {
    var lists: [GTBookStoreADBookItem]?
    var count: Int
    
    enum CodingKeys: String, CodingKey {
        case lists
        case count
    }
    
    struct GTBookStoreADBookItem: Codable {
        var bookId: String
        var adUrl: String
        
        enum CodingKeys: String, CodingKey {
            case bookId
            case adUrl
        }
    }
}
