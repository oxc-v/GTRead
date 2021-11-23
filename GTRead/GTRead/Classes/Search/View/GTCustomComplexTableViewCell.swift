//
//  GTCustomTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/16.
//

import Foundation
import UIKit

class GTCustomComplexTableViewCell: UITableViewCell {

    var imgView: UIImageView!
    var loadingView: GTLoadingView!
    var titleLabel: UILabel!
    var detailLabel: UILabel!
    var button: UIButton!
    var baseView: UIView!
    var buttonClickedEvent: ((_ sender: UIButton) -> Void)?
    
    var isCustomFrame = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        baseView = UIView()
        baseView.backgroundColor = .clear
        baseView.addShadow(offset: CGSize(width: 3, height: 3), color: UIColor.black, radius: 5, opacity: 0.3)
        self.contentView.addSubview(baseView)
        baseView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(20)
//            make.width.equalTo(70)
//            make.height.equalTo(100)
            make.height.equalToSuperview().multipliedBy(0.8)
            make.width.equalTo(baseView.snp.height).multipliedBy(0.7)
        }
        
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.masksToBounds = true
        imgView.layer.cornerRadius = 10
        baseView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.contentView.snp.left)
//            make.width.equalTo(70)
//            make.height.equalTo(95)
            make.width.height.equalToSuperview()
        }
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.lineBreakMode = .byTruncatingMiddle
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-15)
            make.left.equalTo(imgView.snp.right).offset(16)
            make.width.lessThanOrEqualTo(200)
        }
        
        
        detailLabel = UILabel()
        detailLabel.textAlignment = .left
        detailLabel.textColor = UIColor(hexString: "#b4b4b4")
        detailLabel.font = UIFont.boldSystemFont(ofSize: 13)
        detailLabel.lineBreakMode = .byTruncatingMiddle
        self.contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(15)
            make.left.equalTo(imgView.snp.right).offset(16)
            make.width.lessThanOrEqualTo(200)
        }
        
        button = UIButton()
        button.setTitle("添加藏书", for: .normal)
        button.backgroundColor = UIColor(hexString: "#f2f2f6")
        button.layer.cornerRadius = 18
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        self.contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(36)
        }
        
        loadingView = GTLoadingView(colors: [UIColor(hexString: "#12c2e9"), UIColor(hexString: "#c471ed"), UIColor(hexString: "#f64f59")], lineWidth: 3)
        loadingView.isHidden = true
        self.contentView.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.center.equalTo(button.snp.center)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.titleLabel.text = ""
        self.detailLabel.text = ""
        self.imgView.image = nil
        self.buttonClickedEvent = nil
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set(newFrame) {
            var frame = newFrame
            if isCustomFrame {
                let newWidth = UIScreen.main.bounds.width - GTViewMargin * 2
                let space = (frame.width - newWidth) / 2
                frame.size.width = newWidth
                frame.origin.x += space
            }
            super.frame = frame
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Button clicked
    @objc private func buttonClicked(sender: UIButton) {
        loadingView.isHidden = false
        loadingView.isAnimating = true
        sender.isHidden = true
        buttonClickedEvent?(sender)
    }
}
