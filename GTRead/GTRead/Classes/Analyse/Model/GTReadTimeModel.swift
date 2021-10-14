//
//  GTReadTimeModel.swift
//  GTRead
//
//  Created by Dev on 2021/9/26.
//
import UIKit

//阅读时间数据模型
struct GTReadTimeModel: Codable {
    var lists: [GTReadTimeItem]
    
    enum CodingKeys: String, CodingKey {
        case lists
    }
    
    struct GTReadTimeItem: Codable {
        var min: Double
        
        enum CodingKeys: String, CodingKey {
            case min
        }
    }
}
