//
//  GTCommentNavigationController.swift
//  GTRead
//
//  Created by Dev on 2022/1/4.
//

import Foundation
import UIKit

class GTCommentNavigationController: UINavigationController {
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = CGFloat(120)
        navigationBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height)
    }
}
