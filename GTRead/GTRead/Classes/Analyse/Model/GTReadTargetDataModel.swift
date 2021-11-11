//
//  GTReadTargetDataModel.swift
//  GTRead
//
//  Created by Dev on 2021/11/11.
//

import Foundation
import UIKit

struct GTReadTargetDataModel: Codable {
    var minute: Int
    
    enum CodingKeys: String, CodingKey {
        case minute
    }
}
