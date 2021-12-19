//
//  GTUserDefault.swift
//  GTRead
//
//  Created by Dev on 2021/11/29.
//

import Foundation
import UIKit

final class GTUserDefault {
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private let ioQueue: DispatchQueue
    private let ioQueueName = "com.GTDisk.Cache.IoQueue."
    
    // 采用单例模式
    static let shared = GTUserDefault()
    
    private init() {
        // 初始化解码器和编码器
        decoder = JSONDecoder()
        encoder = JSONEncoder()
        ioQueue = DispatchQueue(label: ioQueueName, attributes: [])
    }
    
    func set<T: Encodable>(_ value: T?, forKey defaultName: String) {
        if let data = try? encoder.encode(value) {
            UserDefaults.standard.set(data, forKey: defaultName)
        } else {
            print("GTUserDefault Set Error!!!")
        }
    }
    
    func data<T: Decodable>(forKey defaultName: String) -> T? {
        if let data = UserDefaults.standard.data(forKey: defaultName) {
            if let enData = try? decoder.decode(T.self, from: data) {
                return enData
            }
        }
        
        return nil
    }
}
