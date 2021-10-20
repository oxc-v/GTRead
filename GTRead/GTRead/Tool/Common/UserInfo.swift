//
//  Common.swift
//  GTRead
//
//  Created by Dev on 2021/4/22.
//

import UIKit

// 用户信息
struct UserDefaultKeys {
    // 账户信息
    struct AccountInfo {
        static let nickname = "nickname"
        static let password = "password"
        static let account = "account"
    }
}

// 登录状态
struct LoginStatus {
    static var isLogin = false
}
