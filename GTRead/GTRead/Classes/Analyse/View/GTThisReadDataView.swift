//
//  GTReadThisReadDataView.swift
//  GTRead
//
//  Created by Dev on 2021/10/18.
//

import UIKit

class GTThisReadDataView: UIView {
    
    var titleLabel: UILabel!
    var dataLabel: UILabel!
    var imgView: UIImageView!
    var titleTxt: String!
    var dataTxt: String!
    var imgName: String!
    var dataModel: GTAnalyseDataModel?
    
    init(titleTxt: String, dataTxt: String, imgName: String) {
        super.init(frame: CGRect())
        
        self.backgroundColor = UIColor.white
//        self.layer.shadowRadius = 5
//        self.layer.shadowOffset = CGSize(width: 3.0, height: -3.0)
//        self.layer.shadowOpacity = 0.1
        
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.image = UIImage(named: imgName)
        self.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.height.width.equalTo(50)
            make.left.top.equalTo(16)
        }
        
        dataLabel = UILabel()
        dataLabel.text = dataTxt
        dataLabel.font = dataLabel.font.withSize(30)
        self.addSubview(dataLabel)
        dataLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.left)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        titleLabel = UILabel()
        titleLabel.text = titleTxt
        titleLabel.textColor = UIColor(hexString: "#b4b4b4")
        titleLabel.font = titleLabel.font.withSize(12)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.left)
            make.bottom.equalTo(dataLabel.snp.top).offset(-10)
        }
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 清空数据
    func clearData() {
        dataLabel.text = ""
    }
    
    // 更新数据
    func updateWithData(text: String) {
        dataLabel.text = text
    }
}
