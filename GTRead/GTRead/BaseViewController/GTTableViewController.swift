//
//  GTTableViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/20.
//

import Foundation
import UIKit
import SwiftEntryKit
import NVActivityIndicatorView

class GTTableViewController: UITableViewController {
    
    private var activityIndicatorView: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.midX - 40, y: UIScreen.main.bounds.midY - 25, width: 80, height: 50), type: .lineScalePulseOut, color: .black, padding: 10)
        activityIndicatorView.layer.zPosition = 100
        self.view.addSubview(activityIndicatorView)
    }
    
    // 显示loading view
    func showActivityIndicatorView() {
        activityIndicatorView.startAnimating()
    }
    
    // 隐藏loading view
    func hideActivityIndicatorView() {
        activityIndicatorView.stopAnimating()
    }
    
    // 显示通知
    func showNotificationMessageView(message: String) {
        var attributes = EKAttributes.topFloat
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.statusBar = .dark
        attributes.screenInteraction = .forward
        attributes.entryBackground = .color(color: .white)
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.2)))
        let widthConstraint = EKAttributes.PositionConstraints.Edge.intrinsic
        let heightConstraint = EKAttributes.PositionConstraints.Edge.offset(value: 10)
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        attributes.roundCorners = .all(radius: 20)
        let title = EKProperty.LabelContent(text: message, style: .init(font: UIFont.boldSystemFont(ofSize: 16), color: .black))
        let description = EKProperty.LabelContent(text: "", style: .init(font: UIFont.systemFont(ofSize: 10), color: .black))
        let simpleMessage = EKSimpleMessage(image: nil, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)

        let contentView = EKNotificationMessageView(with: notificationMessage)
       
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
}
