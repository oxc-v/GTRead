//
//  GTPDFPageDataModel.swift
//  GTRead
//
//  Created by Dev on 2021/11/13.
//

import Foundation
import UIKit

struct GTPDFPageDataModel: Codable{
    var lists: [GTPDFPageDataItem]
    
    enum CodingKeys: String, CodingKey {
        case lists
    }
}

struct GTPDFPageDataItem: Codable {
    var bookId: String
    var page: Int
    
    enum CodingKeys: String, CodingKey {
        case bookId
        case page
    }
}
