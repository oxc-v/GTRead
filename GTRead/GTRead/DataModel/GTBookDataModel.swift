//
//  GTBookDataModel.swift
//  GTRead
//
//  Created by Dev on 2021/11/18.
//

import Foundation
import UIKit

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
