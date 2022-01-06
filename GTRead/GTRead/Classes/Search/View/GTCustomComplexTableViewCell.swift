//
//  GTCustomTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/16.
//

import Foundation
import UIKit
import Cosmos

class GTCustomComplexTableViewCell: UITableViewCell {

    private var gtImgView: GTShadowImageView!
    
    var imgView: UIImageView!
    var loadingView: GTLoadingView!
    var titleLabel: UILabel!
    var detailLabel: UILabel!
    var button: UIButton!
    var cosmosView: CosmosView!
    
    var buttonClickedEvent: ((_ sender: UIButton) -> Void)? 
    
    var isCustomFrame = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        gtImgView = GTShadowImageView()
        gtImgView.imgView.contentMode = .scaleAspectFill
        gtImgView.imgView.clipsToBounds = true
        gtImgView.imgView.layer.masksToBounds = true
        gtImgView.imgView.layer.cornerRadius = 5
        imgView = gtImgView.imgView
        self.contentView.addSubview(gtImgView)
        gtImgView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.8)
            make.width.equalTo(gtImgView.snp.height).multipliedBy(0.7)
        }
        
        button = UIButton()
        button.setTitle("添加书库", for: .normal)
        button.backgroundColor = UIColor(hexString: "#f2f2f6")
        button.layer.cornerRadius = 15
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        self.contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
        detailLabel = UILabel()
        detailLabel.textAlignment = .left
        detailLabel.textColor = UIColor(hexString: "#b4b4b4")
        detailLabel.font = UIFont.boldSystemFont(ofSize: 13)
        detailLabel.lineBreakMode = .byTruncatingMiddle
        self.contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(gtImgView.snp.right).offset(16)
            make.right.equalTo(button.snp.left).offset(-20)
        }
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.lineBreakMode = .byTruncatingMiddle
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(detailLabel.snp.top).offset(-5)
            make.left.equalTo(gtImgView.snp.right).offset(16)
            make.right.equalTo(button.snp.left).offset(-20)
        }
        
        cosmosView = CosmosView()
        cosmosView.settings.fillMode = .precise
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.starSize = 12
        cosmosView.settings.starMargin = 3
        cosmosView.settings.filledImage = UIImage(named: "star_fill")
        cosmosView.settings.emptyImage = UIImage(named: "star_empty")
        self.contentView.addSubview(cosmosView)
        cosmosView.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(5)
            make.left.equalTo(gtImgView.snp.right).offset(16)
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
        
        cosmosView.prepareForReuse()
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.titleLabel.text = ""
        self.detailLabel.text = ""
        self.imgView.image = nil
        self.buttonClickedEvent = nil
        self.loadingView.isHidden = true
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
