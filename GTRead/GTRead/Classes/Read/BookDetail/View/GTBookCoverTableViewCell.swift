//
//  GTBookCoverViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/23.
//

import Foundation
import UIKit

class GTBookCoverTableViewCell: UITableViewCell {
    
    private var baseView: UIView!
    private var loadingView: GTLoadingView!
    private var imgView: UIImageView!
    private var titleLabel: UILabel!
    private var detailLabel: UILabel!
    private var startReadBtn: UIButton!
    private var addShelfBtn: UIButton!
    private var editCommentBtn: UIButton!
    
    private let cellHeight = 400.0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        baseView = UIView()
        baseView.backgroundColor = .clear
        baseView.addShadow(offset: CGSize(width: 3, height: 3), color: UIColor.black, radius: 5, opacity: 0.3)
        self.contentView.addSubview(baseView)
        baseView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(20)
            make.height.equalToSuperview().multipliedBy(0.8)
            make.width.equalTo(baseView.snp.height).multipliedBy(0.7)
        }
        
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.masksToBounds = true
        imgView.layer.cornerRadius = 10
        imgView.image = UIImage(named: "book_placeholder")
        baseView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.contentView.snp.left)
            make.width.height.equalToSuperview()
        }
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.text = "破极·暗夜凶光"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.lineBreakMode = .byTruncatingMiddle
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imgView.snp.top).offset(15)
            make.left.equalTo(imgView.snp.right).offset(50)
            make.right.equalToSuperview().offset(-50)
        }
        
        detailLabel = UILabel()
        detailLabel.textAlignment = .left
        detailLabel.text = "逆天而行"
        detailLabel.textColor = .black
        detailLabel.font = UIFont.boldSystemFont(ofSize: 19)
        detailLabel.lineBreakMode = .byTruncatingMiddle
        self.contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(titleLabel.snp.left)
            make.width.lessThanOrEqualTo(300)
        }
        
        startReadBtn = UIButton()
        startReadBtn.setTitle("开始阅读", for: .normal)
        startReadBtn.backgroundColor = .black
        startReadBtn.setTitleColor(.white, for: .normal)
        startReadBtn.titleLabel?.textAlignment = .center
        startReadBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        startReadBtn.layer.cornerRadius = 25
        self.contentView.addSubview(startReadBtn)
        startReadBtn.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalToSuperview()
            make.height.equalTo(50)
            make.bottom.equalTo(imgView.snp.bottom).offset(-50 - 20)
        }
        
        addShelfBtn = UIButton()
        var addShelfBtnConfig = UIButton.Configuration.plain()
        addShelfBtnConfig.imagePadding = 5
        addShelfBtnConfig.title = "添加书库"
        addShelfBtnConfig.baseForegroundColor = .black
        addShelfBtnConfig.attributedTitle?.font = UIFont.boldSystemFont(ofSize: 16)
        addShelfBtn.configuration = addShelfBtnConfig
        addShelfBtn.layer.borderWidth = 2
        addShelfBtn.setImage(UIImage(named: "add_shelf"), for: .normal)
        addShelfBtn.backgroundColor = .white
        addShelfBtn.layer.cornerRadius = 25
        self.contentView.addSubview(addShelfBtn)
        addShelfBtn.snp.makeConstraints { make in
            make.left.equalTo(detailLabel.snp.left)
            make.bottom.equalTo(imgView.snp.bottom)
            make.right.equalTo(startReadBtn.snp.centerX).offset(-30)
            make.height.equalTo(startReadBtn.snp.height)
        }
        
        editCommentBtn = UIButton()
        var editCommentBtnConfig = UIButton.Configuration.plain()
        editCommentBtnConfig.imagePadding = 5
        editCommentBtnConfig.title = "评论和评分"
        editCommentBtnConfig.attributedTitle?.font = UIFont.boldSystemFont(ofSize: 16)
        editCommentBtnConfig.baseForegroundColor = .black
        editCommentBtn.configuration = editCommentBtnConfig
        editCommentBtn.layer.borderWidth = 2
        editCommentBtn.setImage(UIImage(named: "edit_comment"), for: .normal)
        editCommentBtn.backgroundColor = .white
        editCommentBtn.layer.cornerRadius = 25
        self.contentView.addSubview(editCommentBtn)
        editCommentBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(startReadBtn.snp.centerX).offset(-20)
            make.bottom.equalTo(imgView.snp.bottom)
            make.height.equalTo(startReadBtn.snp.height)
        }
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {

        let size = CGSize(width: UIScreen.main.bounds.width - GTViewMargin * 2, height: cellHeight)
        return size
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set(newFrame) {
            var frame = newFrame
            let newWidth = 704 - GTViewMargin * 2
            let space = (frame.width - newWidth) / 2
            frame.size.width = newWidth
            frame.origin.x += space
            super.frame = frame
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}