//
//  GTBookDataModel.swift
//  GTRead
//
//  Created by Dev on 2021/11/18.
//

import Foundation
import UIKit

let GTBookTypeLists = ["计算机与互联网", "教育", "经管理财", "科幻奇幻", "悬疑推理", "言情", "文学", "历史", "地理", "政治", "化学", "生物", "物理", "数学"]
let GTBookLanguageTypeForCH = ["简体中文", "英文"]
let GTBookLanguageTypeForEN = ["CH", "EN"]

struct GTBookDataModel: Codable {
    
    var bookId: String
    var baseInfo: GTBookBaseInfoDataModel
    var downInfo: GTBookDownInfoDataModel
    var gradeInfo: GTBookGradeInfoDataModel
    
    enum CodingKeys: String, CodingKey {
        case bookId
        case baseInfo
        case downInfo
        case gradeInfo
    }
}

struct GTBookBaseInfoDataModel: Codable {
    var bookType: Int
    var bookPage: Int
    var languageType: Int
    var bookName: String
    var authorName: String
    var publishTime: String
    var publishHouse: String
    var bookIntro: String
    
    enum CodingKeys: String, CodingKey {
        case bookType
        case bookPage
        case languageType
        case bookName
        case authorName
        case bookIntro
        case publishTime
        case publishHouse
    }
}

struct GTBookDownInfoDataModel: Codable {
    var fileSize: Float
    var bookHeadUrl: String
    var bookDownUrl: String
    
    enum CodingKeys: String, CodingKey {
        case fileSize
        case bookHeadUrl
        case bookDownUrl
    }
}

struct GTBookGradeInfoDataModel: Codable {
    var remarkCount: Int
    var averageScore: Float
    
    enum CodingKeys: String, CodingKey {
        case remarkCount
        case averageScore
    }
}
