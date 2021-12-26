//
//  GTCustomComplexTableViewCellDataModel.swift
//  GTRead
//
//  Created by Dev on 2021/11/21.
//

import Foundation
import UIKit

struct GTCustomComplexTableViewCellDataModel {
    var lists: [GTCustomComplexTableViewCellDataModelItem]?
    var count: Int
}

struct GTCustomComplexTableViewCellDataModelItem {
    var imgUrl: String
    var titleText: String
    var detailText: String
    var rating: Double
    var buttonClickedEvent: ((_ sender: UIButton) -> Void)?
}
