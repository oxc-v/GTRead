//
//  GTAccountInfoDataModel.swift
//  GTRead
//
//  Created by Dev on 2021/11/28.
//

import Foundation
import UIKit

struct GTAccountInfoDataModel: Codable {
    var userId: String
    var nickName: String
    var headImgUrl: String
    var profile: String
    var male: Bool
    var age: Int

    enum CodingKeys: String, CodingKey {
        case userId
        case nickName
        case headImgUrl
        case profile
        case male
        case age
    }
}
