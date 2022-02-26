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

// 书本类型
enum GTBookType: Int, CaseIterable {
    case computer = 0       // 计算与互联网
    case education = 1      // 教育
    case money = 2          // 经管理财
    case science = 3        // 科幻奇幻
    case suspense = 4       // 悬疑推理
    case erotica = 5        // 言情
    case literature = 6     // 文学
    case history = 7        // 历史
    case geography = 8      // 地理
    case politics = 9       // 政治
    case chemistry = 10     // 化学
    case biology = 11       // 生物
    case physics = 12       // 物理
    case math = 13          // 数学
}
