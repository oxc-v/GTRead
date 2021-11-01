//
//  NotificationName.swift
//  GTRead
//
//  Created by Dev on 2021/9/6.
//

import Foundation

// 刷新评论内容通知
let NotiReflashCommentContent = Notification.Name(rawValue: "NotiReflashCommentContent")

// 评论内容折叠状态改变通知
let NotiCommentContentFoldStateChanged = Notification.Name(rawValue: "NotiCommentContentFoldStateChanged")

extension Notification.Name {
    // 登录成功
    static let GTLoginEvent = Notification.Name("GTLoginEvent")
    // 退出登录
    static let GTExitAccount = Notification.Name("GTExitAccount")
}
