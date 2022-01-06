//
//  GTRegisterAccountDataModel.swift
//  GTRead
//
//  Created by Dev on 2022/1/5.
//

import Foundation
import UIKit

struct GTRegisterAccountDataModel: Codable {
    var userId: Int?
    var code: Int
    
    enum CodingKeys: String, CodingKey {
        case userId
        case code
    }
}
