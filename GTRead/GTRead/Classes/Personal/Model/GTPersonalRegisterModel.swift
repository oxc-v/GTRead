//
//  GTPersonalRegisterModel.swift
//  GTRead
//
//  Created by Dev on 2021/9/29.
//

import UIKit

struct GTPersonalRegisterModel: Codable{
    var code: Int
    var errorRes: String?
    enum CodingKeys: String, CodingKey {
        case code
        case errorRes
    }
}
