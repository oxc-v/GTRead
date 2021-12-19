//
//  GTReadTimeModel.swift
//  GTRead
//
//  Created by Dev on 2021/9/26.
//

import UIKit

struct GTAnalyseDataModel: Codable {
    
    var lists: [GTOneDayReadTime]?
    var thisTimeData: GTThisTimeReadData?
    var scatterDiagram: [GTOneDayBehaviour]?
    var speedPoints: [GTReadSpeedData]?
    var status: GTErrorMessage
    
    enum CodingKeys: String, CodingKey {
        case lists
        case thisTimeData
        case scatterDiagram
        case speedPoints
        case status
    }
}

struct GTErrorMessage: Codable {
    var code: Int
    var errorRes: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case errorRes
    }
}

// 一天的阅读时间
struct GTOneDayReadTime: Codable {
    var min: Int
    
    enum CodingKeys: String, CodingKey {
        case min
    }
}

// 本次阅读数据
struct GTThisTimeReadData: Codable {
    var hour: Int
    var min: Int
    var sec: Int
    var focus: Double
    var pages: Int
    var rows: Int
    
    enum CodingKeys: String, CodingKey {
        case hour
        case min
        case sec
        case focus
        case pages
        case rows
    }
}

// 一天的阅读速度
struct GTReadSpeedData: Codable {
    var point: Double
    
    enum CodingKeys: String, CodingKey {
        case point
    }
}

// 一天的行为数据
struct GTOneDayBehaviour: Codable {
    var action: String
    var color: String
    var locate: [GTOneDayBehaviourPoint]
    
    enum CodingKeys: String, CodingKey {
        case action
        case color
        case locate
    }
}

// 一天的行为数据
struct GTOneDayBehaviourPoint: Codable {
    var x: Double
    var y: Double
    
    enum CodingKeys: String, CodingKey {
        case x
        case y
    }
}
