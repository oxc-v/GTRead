//
//  GTBookPublicationInfoCollectionViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/26.
//

import Foundation
import UIKit

class GTBookPublicationInfoCollectionViewCell: UICollectionViewCell {
    
    private var separatorView: UIView!
    var titleLabel: UILabel!
    var imgView: UIImageView!
    var contentLabel: UILabel!
    var subtitleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(hexString: "#b4b4b4")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 13)
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.height.equalTo(15)
        }

        imgView = UIImageView()
        imgView.isHidden = true
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.width.height.equalTo(30)
        }

        contentLabel = UILabel()
        contentLabel.numberOfLines = 0
        contentLabel.textAlignment = .center
        contentLabel.textColor = .black
        contentLabel.font = UIFont.boldSystemFont(ofSize: 23)
        self.contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().offset(-25)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.height.lessThanOrEqualTo(50)
        }

        subtitleLabel = UILabel()
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .black
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        self.contentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().offset(-25)
        }

        separatorView = UIView()
        separatorView.backgroundColor = UIColor(hexString: "#cacacc")
        self.contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalTo(0.5)
            make.right.equalToSuperview()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        imgView.isHidden = true
        subtitleLabel.isHidden = false
        contentLabel.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
