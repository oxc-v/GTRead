//
//  GTBaseViewController.swift
//  GTRead
//
//  Created by YangJie on 2021/2/20.
//

import UIKit
import SwiftEntryKit

class GTBaseViewController: UIViewController {

    private var loadingView: GTLoadingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView = GTLoadingView(colors: [UIColor(hexString: "#12c2e9"), UIColor(hexString: "#c471ed"), UIColor(hexString: "#f64f59")], lineWidth: 5)
        loadingView.layer.zPosition = 100
        loadingView.isAnimating = false
        self.view.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(40)
        }
    }
    
    // 显示loading view
    func showActivityIndicatorView() {
        loadingView.isAnimating = true
    }
    
    // 隐藏loading view
    func hideActivityIndicatorView() {
        loadingView.isAnimating = false
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
    
    // 提示框
    func showWarningAlertController(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
