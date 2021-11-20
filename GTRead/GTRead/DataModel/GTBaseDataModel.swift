//
//  GTBaseDataModel.swift
//  GTRead
//
//  Created by Dev on 2021/11/5.
//

import Foundation
import UIKit

struct GTBaseDataModel: Codable {
    var code: Int
    var errorRes: String?
    enum CodingKeys: String, CodingKey {
        case code
        case errorRes
    }
}
