//
//  GTCommentModel.swift
//  GTRead
//
//  Created by YangJie on 2021/4/23.
//

import UIKit

struct GTCommentModel: Codable{
    var count: Int
    var lists: [GTCommentItem]?
    enum CodingKeys: String, CodingKey {
        case count
        case lists
    }
}

struct GTCommentItem: Codable {
    var timestamp: String
    var userId: String?
    var nickName: String?
    var headUrl: String?
    var commentContent: String?
    var childCount: Int
    var commentId: Int
    var parentId: Int
    var childComments: [GTCommentItem]?
    var unfold: Bool = false
    enum CodingKeys: String, CodingKey {
        case timestamp
        case userId
        case nickName
        case headUrl
        case commentContent
        case childCount
        case childComments
        case commentId
        case parentId
    }
}




