//
//  extension.swift
//  GTRead
//
//  Created by Dev on 2021/11/5.
//

import Foundation
import UIKit

extension Notification.Name {
    
    // 打开登录弹窗
    static let GTOpenLoginView = Notification.Name("GTOpenLoginView")
    
    // 打开注册弹窗
    static let GTOpenRegisterView = Notification.Name("GTOpenRegisterView")
    
    // 打开修改密码弹窗
    static let GTOpenUpdatePwdView = Notification.Name("GTOpenUpdatePwdView")
    
    // 登录成功
    static let GTLoginSuccessful = Notification.Name("GTLoginSuccessful")
    
    // 退出登录
    static let GTExitAccount = Notification.Name("GTExitAccount")
    
    // 退出阅读界面
    static let GTExitReadView = Notification.Name("GTExitReadView")
    
    // 修改用户信息
    static let GTAccountInfoChanged = Notification.Name("GTAccountInfoChanged")
    
    // 每日目标改变
    static let GTReadTargetChanged = Notification.Name("GTReadTargetChanged")
    
    // 重新加载网络
    static let GTLoadNetwork = Notification.Name("GTLoadNetwork")
    
    // 跳转个人主页----将来要删除
    static let GTGoPersonalViewController = Notification.Name("GTGoPersonalViewController")
    
    // 跳转到指定PDF页码
    static let GTGoPDFViewForPage = Notification.Name("GTGoPDFViewForPage")
    
    // 激活UISearchController
    static let GTActivateSearchController = Notification.Name("GTActivateSearchController")
    
    // 添加书籍到书库
    static let GTAddBookToShelf = Notification.Name("GTAddBookToShelf")
    
    // 从书库删除书籍
    static let GTDeleteBookToShelf = Notification.Name("GTDeleteBookToShelf")
    
    // 书本下载完毕
    static let GTDownloadBookFinished = Notification.Name("GTDownloadBookFinished")
    
    // GTExploreMoreBookCell 点击
    static let GTExploreMoreBookCellCollectionViewCellClicked = Notification.Name("GTExploreMoreBookCellCollectionViewCellClicked")
    
    // 书架数据更新
    static let GTShelfDataUpdate = Notification.Name("GTShelfDataUpdate")
    
    // 评论内容筛选选项变化
    static let GTCommentFilterValueChanged = Notification.Name("GTCommentFilterValueChanged")
    
    // 刷新页码评论内容
    static let GTReflashPDFComment = Notification.Name("GTReflashPDFComment")
}

extension UIViewController {
    func setTabBarHidden(_ hidden: Bool, animated: Bool = true, duration: TimeInterval = 0.3) {
        if animated {
            if let frame = self.tabBarController?.tabBar.frame {
                let factor: CGFloat = hidden ? 1 : -1
                let y = frame.origin.y + (frame.size.height * factor)
                UIView.animate(withDuration: duration, animations: {
                    self.tabBarController?.tabBar.frame = CGRect(x: frame.origin.x, y: y, width: frame.width, height: frame.height)
                })
                return
            }
        }
        self.tabBarController?.tabBar.isHidden = hidden
    }
}

extension UIScrollView {
    func updateContentView() {
        contentSize.height = subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY ?? contentSize.height
    }
}

extension Array where Element == CGPoint {
    func medianX() -> Double {
        let sortedArray = sorted { a, b in
            return a.x < b.x
        }
        if count % 2 != 0 {
            return Double(sortedArray[count / 2].x)
        } else {
            return Double(sortedArray[count / 2].x + sortedArray[count / 2 - 1].x) / 2.0
        }
    }
    
    func medianY() -> Double {
        let sortedArray = sorted { a, b in
            return a.y < b.y
        }
        if count % 2 != 0 {
            return Double(sortedArray[count / 2].y)
        } else {
            return Double(sortedArray[count / 2].y + sortedArray[count / 2 - 1].y) / 2.0
        }
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIView {

    /**
     Simply zooming in of a view: set view scale to 0 and zoom to Identity on 'duration' time interval.
     
     - parameter duration: animation duration
     */
    func zoomIn(duration: TimeInterval = 0.2, _ completed: (()->Void)? = nil) {
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            self.transform = .identity
        }) { (animationCompleted: Bool) -> Void in
            completed?()
        }
    }
    
    /**
     Simply zooming out of a view: set view scale to Identity and zoom out to 0 on 'duration' time interval.
     
     - parameter duration: animation duration
     */
    func zoomOut(duration : TimeInterval = 0.2, _ completed: (()->Void)? = nil) {
        self.transform = .identity
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }) { (animationCompleted: Bool) -> Void in
            completed?()
        }
    }
    
    /**
     Zoom in any view with specified offset magnification.
     
     - parameter duration:     animation duration.
     - parameter easingOffset: easing offset.
     */
    func zoomInWithEasing(duration: TimeInterval = 0.2, easingOffset: CGFloat = 0.2) {
        let easeScale = 1.0 + easingOffset
        let easingDuration = TimeInterval(easingOffset) * duration / TimeInterval(easeScale)
        let scalingDuration = duration - easingDuration
        UIView.animate(withDuration: scalingDuration, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: easeScale, y: easeScale)
        }, completion: { (completed: Bool) -> Void in
            UIView.animate(withDuration: easingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.transform = .identity
                }, completion: { (completed: Bool) -> Void in
                })
        })
    }
    
    /**
     Zoom out any view with specified offset magnification.
     
     - parameter duration:     animation duration.
     - parameter easingOffset: easing offset.
     */
    func zoomOutWithEasing(duration: TimeInterval = 0.2, easingOffset: CGFloat = 0.2) {
        let easeScale = 1.0 + easingOffset
        let easingDuration = TimeInterval(easingOffset) * duration / TimeInterval(easeScale)
        let scalingDuration = duration - easingDuration
        UIView.animate(withDuration: easingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: easeScale, y: easeScale)
        }, completion: { (completed: Bool) -> Void in
            UIView.animate(withDuration: scalingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                }, completion: { (completed: Bool) -> Void in
                })
        })
    }
    
    func clickedAnimation(withDuration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        self.transform = CGAffineTransform(scaleX: 0.9, y: 1.2)
        UIView.animate(withDuration: withDuration, delay: 0, usingSpringWithDamping: CGFloat(0.20), initialSpringVelocity: CGFloat(6.0), options: UIView.AnimationOptions.allowUserInteraction, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: { ok in
            completion?(ok)
        })
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UITextView {
    func centerVerticalText() {
        let fitSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fitSize)
        let calculate = (bounds.size.height - size.height * zoomScale) / 2
        let offset = max(1, calculate)
        contentOffset.y = -offset
    }
}

extension String {
    
    func timeIntervalChangeToTimeStr(_ dateFormat: String? = "yyyy-MM-dd HH:mm") -> String {
        let timeInterval = Double(self) ?? 0
        let date:Date = Date.init(timeIntervalSince1970: timeInterval)
        let formatter = DateFormatter.init()
        if dateFormat == nil {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        } else{
            formatter.dateFormat = dateFormat
        }
        
        return formatter.string(from: date as Date)
    }
    
    func utf8DecodedString()-> String {
        let data = self.data(using: .utf8)
        let message = String(data: data!, encoding: .nonLossyASCII) ?? ""
        return message
    }
        
    func utf8EncodedString()-> String {
        let messageData = self.data(using: .nonLossyASCII, allowLossyConversion: true)
        let text = String(data: messageData!, encoding: .utf8) ?? ""
        return text
    }
    
    subscript(_ indexs: ClosedRange<Int>) -> String {
        let beginIndex = index(startIndex, offsetBy: indexs.lowerBound)
        let endIndex = index(startIndex, offsetBy: indexs.upperBound)
        return String(self[beginIndex...endIndex])
    }
    
    subscript(_ indexs: Range<Int>) -> String {
        let beginIndex = index(startIndex, offsetBy: indexs.lowerBound)
        let endIndex = index(startIndex, offsetBy: indexs.upperBound)
        return String(self[beginIndex..<endIndex])
    }
    
    subscript(_ indexs: PartialRangeThrough<Int>) -> String {
        let endIndex = index(startIndex, offsetBy: indexs.upperBound)
        return String(self[startIndex...endIndex])
    }
    
    subscript(_ indexs: PartialRangeFrom<Int>) -> String {
        let beginIndex = index(startIndex, offsetBy: indexs.lowerBound)
        return String(self[beginIndex..<endIndex])
    }
    
    subscript(_ indexs: PartialRangeUpTo<Int>) -> String {
        let endIndex = index(startIndex, offsetBy: indexs.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

