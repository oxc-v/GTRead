//
//  GTBookGradeCollectionViewCell.swift
//  GTRead
//
//  Created by Dev on 2022/1/4.
//

import Foundation
import UIKit
import Cosmos

class GTBookGradeCollectionViewCell: UICollectionViewCell {
    
    var gradeLab: UILabel!
    private var gradeSubLab: UILabel!
    
    private var startView_1: UIImageView!
    private var startView_2: UIImageView!
    private var startView_3: UIImageView!
    private var startView_4: UIImageView!
    private var startView_5: UIImageView!
    var progressView_1: UIProgressView!
    var progressView_2: UIProgressView!
    var progressView_3: UIProgressView!
    var progressView_4: UIProgressView!
    var progressView_5: UIProgressView!
    var numberLab: UILabel!
    
    private let progressHeight = 3
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    private func setupView() {
        
        gradeLab = UILabel()
        gradeLab.font = UIFont.boldSystemFont(ofSize: 45)
        gradeLab.textAlignment = .left
        self.contentView.addSubview(gradeLab)
        gradeLab.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
            make.height.equalTo(65)
        }
        
        gradeSubLab = UILabel()
        gradeSubLab.font = UIFont.systemFont(ofSize: 15)
        gradeSubLab.text = "(共5分)"
        self.contentView.addSubview(gradeSubLab)
        gradeSubLab.snp.makeConstraints { make in
            make.centerX.equalTo(gradeLab.snp.centerX)
            make.top.equalTo(gradeLab.snp.bottom)
        }
        
        startView_1 = UIImageView()
        startView_1.contentMode = .scaleAspectFit
        startView_1.image = UIImage(named: "star_5")
        self.contentView.addSubview(startView_1)
        startView_1.snp.makeConstraints { make in
            make.right.equalTo(-180)
            make.top.equalTo(gradeLab.snp.top)
            make.width.equalTo(50)
            make.height.equalTo(10)
        }
        
        startView_2 = UIImageView()
        startView_2.contentMode = .scaleAspectFit
        startView_2.image = UIImage(named: "star_4")
        self.contentView.addSubview(startView_2)
        startView_2.snp.makeConstraints { make in
            make.right.equalTo(startView_1.snp.right)
            make.top.equalTo(startView_1.snp.bottom).offset(1)
            make.width.equalTo(40)
            make.height.equalTo(10)
        }
        
        startView_3 = UIImageView()
        startView_3.contentMode = .scaleAspectFit
        startView_3.image = UIImage(named: "star_3")
        self.contentView.addSubview(startView_3)
        startView_3.snp.makeConstraints { make in
            make.right.equalTo(startView_1.snp.right)
            make.top.equalTo(startView_2.snp.bottom).offset(1)
            make.width.equalTo(30)
            make.height.equalTo(10)
        }
        
        startView_4 = UIImageView()
        startView_4.contentMode = .scaleAspectFit
        startView_4.image = UIImage(named: "star_2")
        self.contentView.addSubview(startView_4)
        startView_4.snp.makeConstraints { make in
            make.right.equalTo(startView_1.snp.right)
            make.top.equalTo(startView_3.snp.bottom).offset(1)
            make.width.equalTo(20)
            make.height.equalTo(10)
        }
        
        startView_5 = UIImageView()
        startView_5.contentMode = .scaleAspectFit
        startView_5.image = UIImage(named: "star_1")
        self.contentView.addSubview(startView_5)
        startView_5.snp.makeConstraints { make in
            make.right.equalTo(startView_1.snp.right)
            make.top.equalTo(startView_4.snp.bottom).offset(1)
            make.width.equalTo(10)
            make.height.equalTo(10)
        }
        
        progressView_1 = UIProgressView()
        progressView_1.setProgress(0.5, animated: true)
        progressView_1.progressTintColor = .black
        self.contentView.addSubview(progressView_1)
        progressView_1.snp.makeConstraints { make in
            make.height.equalTo(progressHeight)
            make.centerY.equalTo(startView_1.snp.centerY)
            make.width.equalTo(150)
            make.right.equalTo(-20)
        }
        
        progressView_2 = UIProgressView()
        progressView_2.progressTintColor = .black
        progressView_2.setProgress(0.2, animated: true)
        self.contentView.addSubview(progressView_2)
        progressView_2.snp.makeConstraints { make in
            make.height.equalTo(progressHeight)
            make.centerY.equalTo(startView_2.snp.centerY)
            make.width.equalTo(150)
            make.right.equalTo(-20)
        }
        
        progressView_3 = UIProgressView()
        progressView_3.progressTintColor = .black
        progressView_3.setProgress(0.2, animated: true)
        self.contentView.addSubview(progressView_3)
        progressView_3.snp.makeConstraints { make in
            make.height.equalTo(progressHeight)
            make.centerY.equalTo(startView_3.snp.centerY)
            make.width.equalTo(150)
            make.right.equalTo(-20)
        }
        
        progressView_4 = UIProgressView()
        progressView_4.progressTintColor = .black
        progressView_4.setProgress(0.05, animated: true)
        self.contentView.addSubview(progressView_4)
        progressView_4.snp.makeConstraints { make in
            make.height.equalTo(progressHeight)
            make.centerY.equalTo(startView_4.snp.centerY)
            make.width.equalTo(150)
            make.right.equalTo(-20)
        }
        
        progressView_5 = UIProgressView()
        progressView_5.progressTintColor = .black
        progressView_5.setProgress(0.05, animated: true)
        self.contentView.addSubview(progressView_5)
        progressView_5.snp.makeConstraints { make in
            make.height.equalTo(progressHeight)
            make.centerY.equalTo(startView_5.snp.centerY)
            make.width.equalTo(150)
            make.right.equalTo(-20)
        }
        
        numberLab = UILabel()
        numberLab.font = UIFont.systemFont(ofSize: 15)
        numberLab.textAlignment = .right
        self.contentView.addSubview(numberLab)
        numberLab.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.bottom.equalTo(gradeSubLab.snp.bottom)
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 90)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
