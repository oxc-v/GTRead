//
//  GTPartitionTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/26.
//

import Foundation
import UIKit

class GTSubareaTableViewCell: UITableViewCell {
    
    private var imgView: UIImageView!
    private var btn: UIButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set(newFrame) {
            var frame = newFrame
            let newWidth = UIScreen.main.bounds.width - GTViewMargin * 2
            let space = (frame.width - newWidth) / 2
            frame.size.width = newWidth
            frame.origin.x += space
            super.frame = frame
        }
    }
    
    private func setupView() {
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.image = UIImage(named: "partition")
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.bottom.equalTo(-15)
            make.top.equalTo(15)
            make.width.equalTo(imgView.snp.height)
            make.left.equalToSuperview()
        }
        
        btn = UIButton()
        btn.isEnabled = false
        btn.setTitle("浏览分区", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btn.setImage(UIImage(named: "right_>"), for: .normal)
        btn.semanticContentAttribute = .forceRightToLeft
        btn.contentHorizontalAlignment = .left
        self.contentView.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
    }
}
