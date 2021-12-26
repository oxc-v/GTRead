//
//  GTReadDetailCollectionViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/19.
//

import Foundation
import UIKit

class GTReadDetailCollectionViewCell: UICollectionViewCell {
    
    private var titleLabel: UILabel!
    private var dataLabel: UILabel!
    private var imgView: UIImageView!
    private var baseView: GTShadowView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    private func setupView() {

        baseView = GTShadowView(opacity: 0.1)
        baseView.backgroundColor = .white
        baseView.layer.cornerRadius = 10
        self.contentView.addSubview(baseView)
        baseView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        self.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.height.width.equalTo(50)
            make.left.top.equalTo(16)
        }
        
        dataLabel = UILabel()
        dataLabel.font = dataLabel.font.withSize(30)
        self.addSubview(dataLabel)
        dataLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.left)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        titleLabel = UILabel()
        titleLabel.textColor = UIColor(hexString: "#b4b4b4")
        titleLabel.font = titleLabel.font.withSize(12)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.left)
            make.bottom.equalTo(dataLabel.snp.top).offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imgView.image = nil
        dataLabel.text = ""
        titleLabel.text = ""
    }
    
    func setupViewData(img: String, dataTxt: String, titleTxt: String) {
        imgView.image = UIImage(named: img)
        dataLabel.text = dataTxt
        titleLabel.text = titleTxt
    }
}
