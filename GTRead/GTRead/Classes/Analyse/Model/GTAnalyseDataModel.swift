//
//  GTReadTimeModel.swift
//  GTRead
//
//  Created by Dev on 2021/9/26.
//

import UIKit

struct GTAnalyseDataModel: Codable {
    
    var hour: Int?
    var min: Int?
    var sec: Int?
    var focus: Float?
    var pages: Int?
    var rows: Int?
    var speedPoints: [Float]?
    var timeLists: [Int]?
    var pipChart: [GTPipChart]?
    var status: GTErrorMessage
    
    enum CodingKeys: String, CodingKey {
        case hour
        case min
        case sec
        case focus
        case pages
        case rows
        case speedPoints
        case timeLists
        case pipChart
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

struct GTPipChart: Codable {
    var behavior: String
    var Percentage: Float
    
    enum CodingKeys: String, CodingKey {
        case behavior
        case Percentage
    }
}
