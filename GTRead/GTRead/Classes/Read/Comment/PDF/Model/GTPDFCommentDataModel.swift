//
//  GTPDFCommentDataModel.swift
//  GTRead
//
//  Created by Dev on 2022/2/21.
//

import Foundation

struct GTPDFCommentDataModel: Codable {
    
    var lists: [GTPDFCommentItem]?
    var count: Int
    var errorRes: String?
    
    enum CodingKeys: String, CodingKey {
        case lists
        case count
        case errorRes
    }
}

struct GTPDFCommentItem: Codable {
    
    var title: String
    var reviewer: Int
    var replyCount: Int
    var content: String
    var nickname: String
    var headUrl: String
    var remarkTime: String
    var isHited: Int
    var hitCount: Int
    var commentId: Int
    
    enum CodingKeys: String, CodingKey {
        case title
        case content
        case nickname
        case headUrl
        case remarkTime
        case isHited
        case hitCount
        case replyCount
        case reviewer
        case commentId
    }
}
