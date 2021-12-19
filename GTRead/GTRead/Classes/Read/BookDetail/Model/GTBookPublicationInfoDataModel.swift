//
//  GTBookPublicationInfoDataModel.swift
//  GTRead
//
//  Created by Dev on 2021/11/30.
//

import Foundation
import UIKit

struct GTBookPublicationInfoDataModel {
    var lists: [GTBookPublicationInfoDataModelItem]
}

struct GTBookPublicationInfoDataModelItem {
    var imgName: String
    var contentLabelText: String
    var subtitleLabelText: String
}
