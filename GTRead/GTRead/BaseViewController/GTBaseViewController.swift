//
//  GTBaseViewController.swift
//  GTRead
//
//  Created by YangJie on 2021/2/20.
//

import UIKit
import SwiftEntryKit
import NVActivityIndicatorView
class GTBaseViewController: UIViewController {
    
    private var activityIndicatorView: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.midX - 60, y: UIScreen.main.bounds.midY - 35, width: 120, height: 70), type: .lineScalePulseOut, color: UIColor(hexString: "#6581fb"), padding: 10)
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
    
    // 提示框
    func showWarningAlertController(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // 未登录提示框
    func showNotLoginAlertController(_ title: String, handler: ((UIAlertAction)->Void)?) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let canncelAction = UIAlertAction(title: "取消", style: .default)
        let okAction = UIAlertAction(title: "登录/注册", style: .default, handler: handler)
        alertController.addAction(canncelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
