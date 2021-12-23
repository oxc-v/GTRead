//
//  GTTableViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/20.
//

import Foundation
import UIKit
import SwiftEntryKit
import Presentr
import SDWebImage

class GTTableViewController: UITableViewController {
    
    private var loadingView: GTLoadingView!
    private var notLoginView: GTGoLoginView!
    
    private let presenter: Presentr = {
        let width = ModalSize.fluid(percentage: 0.65)
        let height = ModalSize.fluid(percentage: 0.5)
        let center = ModalCenterPosition.custom(centerPoint: CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY))
        let customType = PresentationType.custom(width: width, height: height, center: center)
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.roundCorners = true
        customPresenter.cornerRadius = 12
        customPresenter.transitionType = .coverVertical
        customPresenter.dismissTransitionType = .coverVertical
        customPresenter.dismissOnSwipe = true
        customPresenter.backgroundOpacity = 0.3
        customPresenter.dismissOnSwipeDirection = .default
        customPresenter.keyboardTranslationType = .moveUp
        return customPresenter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置加载动画
        self.setupLoadingView()
        // 设置登录提示视图
        self.setupNotLoginView()
    }
    
    // 设置登录提示视图
    private func setupNotLoginView() {
        notLoginView = GTGoLoginView()
        notLoginView.isHidden = true
        self.tableView.addSubview(notLoginView)
        notLoginView.snp.makeConstraints { make in
            make.width.height.equalTo(580)
            make.center.equalToSuperview()
        }
    }
    
    // 控制显示登录提示视图---供子类使用
    func showNotLoginView(_ show: Bool) {
        self.notLoginView.isHidden = !show
    }
    
    func getPresenter(widthFluid: Float, heightFluid: Float) -> Presentr {
        let width = ModalSize.fluid(percentage: widthFluid)
        let height = ModalSize.fluid(percentage: heightFluid)
        let center = ModalCenterPosition.custom(centerPoint: CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY))
        let customType = PresentationType.custom(width: width, height: height, center: center)
        presenter.presentationType = customType
        return presenter
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
    
    // 显示登录/注册弹窗----供子类选择
    func showLoginAlertController() {
        let alertController = UIAlertController(title: "咱要做一个有身份的人哟", message: nil, preferredStyle: .alert)
        let loginAction = UIAlertAction(title: "登录", style: .default) {
                    (action: UIAlertAction!) -> Void in
            NotificationCenter.default.post(name: .GTOpenLoginView, object: self)
        }
        let registerAction = UIAlertAction(title: "注册", style: .default) {
                    (action: UIAlertAction!) -> Void in
            NotificationCenter.default.post(name: .GTOpenRegisterView, object: self)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        alertController.addAction(loginAction)
        alertController.addAction(registerAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // 设置加载动画
    private func setupLoadingView() {
        loadingView = GTLoadingView(colors: [UIColor(hexString: "#12c2e9"), UIColor(hexString: "#c471ed"), UIColor(hexString: "#f64f59")], lineWidth: 5)
        loadingView.layer.zPosition = 100
        loadingView.isAnimating = false
        self.tableView.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(40)
        }
    }
    
    // 显示loading view----供子类使用
    func showActivityIndicatorView() {
        loadingView.isAnimating = true
    }
    
    // 隐藏loading view----供子类使用
    func hideActivityIndicatorView() {
        loadingView.isAnimating = false
    }
}
