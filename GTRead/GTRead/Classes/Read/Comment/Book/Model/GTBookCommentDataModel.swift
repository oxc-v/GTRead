//
//  GTBookCommentDataModel.swift
//  GTRead
//
//  Created by Dev on 2022/1/10.
//

import Foundation

struct GTBookCommentDataModel: Codable {
    
    var lists: [GTBookCommentItem]?
    var count: Int
    var errorRes: String?
    
    enum CodingKeys: String, CodingKey {
        case lists
        case count
        case errorRes
    }
}

struct GTBookCommentItem: Codable {
    
    var title: String
    var content: String
    var score: Float
    var praised: Int
    var nickName: String
    var headUrl: String
    var remarkTime: String
    var bookId: String
    var isHit: Bool
    var hitCount: Int
    
    enum CodingKeys: String, CodingKey {
        case title
        case content
        case score
        case praised
        case nickName
        case headUrl
        case remarkTime
        case bookId
        case isHit
        case hitCount
    }
}
