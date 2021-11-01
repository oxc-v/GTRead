//
//  GTPersonalInfoModel.swift
//  GTRead
//
//  Created by Dev on 2021/9/29.
//

import UIKit

struct GTPersonalInfoModel: Codable{
    var userId: String
    var nickName: String
    var headImgUrl: String
    var profile: String
    var male: Bool
    var age: Int
    var userPwd: String?
    enum CodingKeys: String, CodingKey {
        case userId
        case nickName
        case headImgUrl
        case profile
        case male
        case age
        case userPwd
    }
}

