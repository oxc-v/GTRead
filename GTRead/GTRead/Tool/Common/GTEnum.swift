//
//  GTEnum.swift
//  GTRead
//
//  Created by Dev on 2022/1/9.
//

import Foundation

// 分类搜索
enum GTSearchType: String {
    case bookName = "bookName"
    case authorName = "authorName"
    case publishHouse = "publishHouse"
}

// 书籍评论的筛选类型
enum GTBookCommentPattern: Int {
    case time = 0
    case hit = 1
    case score = 2
}

// PDF评论的筛选类型
enum GTPDFCommentPattern: Int {
    case time = 0
    case hit = 1
}
