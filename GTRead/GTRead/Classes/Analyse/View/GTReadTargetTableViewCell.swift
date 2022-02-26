//
//  GTReadTimeTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/19.
//

import Foundation
import UIKit

class GTReadTargetTableViewCell: UITableViewCell {
    
    var titleLabel: UILabel!
    var subTitleLabel: UILabel!
    var titleTwoLabel: UILabel!
    var subTitleTowLabel: UILabel!
    var timeLabel: UILabel!
    var targetBtn: UIButton!
    var goStoreBtn: UIButton!
    var progressView: GTCircleProgressView!
    
    private var totalMinTime = 0
    private var minute: Int
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        let m = UserDefaults.standard.integer(forKey: GTUserDefaultKeys.EveryDayReadTarget.target)
        minute = m == 0 ? 60 : m
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupLabel()
        
        // 每日阅读目标改变通知
        NotificationCenter.default.addObserver(self, selector: #selector(targetChanged), name: .GTReadTargetChanged, object: nil)
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
    
    private func setupLabel() {
        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.black
        titleLabel.text = "阅读目标"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 23)
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
        }
        
        subTitleLabel = UILabel()
        subTitleLabel.textAlignment = .center
        subTitleLabel.textColor = UIColor(hexString: "#b4b4b4")
        subTitleLabel.text = "找一本好书，设定一个目标，养成每天阅读的习惯。"
        subTitleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        self.contentView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        progressView = GTCircleProgressView()
        self.contentView.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(580)
            make.height.equalTo(290)
            make.top.equalTo(subTitleLabel.snp.bottom).offset(30)
        }
        
        titleTwoLabel = UILabel()
        titleTwoLabel.textAlignment = .center
        titleTwoLabel.textColor = UIColor.black
        titleTwoLabel.text = "今日阅读进度"
        titleTwoLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.contentView.addSubview(titleTwoLabel)
        titleTwoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(subTitleLabel.snp.bottom).offset(80)
        }
        
        subTitleTowLabel = UILabel()
        subTitleTowLabel.textAlignment = .center
        subTitleTowLabel.textColor = UIColor(hexString: "#199dd7")
        subTitleTowLabel.text = "还需" + String(minute - totalMinTime <= 0 ? 0 : minute - totalMinTime) + "分钟"
        subTitleTowLabel.font = UIFont.systemFont(ofSize: 23)
        self.contentView.addSubview(subTitleTowLabel)
        subTitleTowLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleTwoLabel.snp.bottom).offset(10)
        }
        
        timeLabel = UILabel()
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.systemFont(ofSize: 75)
        timeLabel.textColor = UIColor.black
        timeLabel.text = "0:00"
        self.contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(subTitleTowLabel.snp.bottom).offset(10)
        }
        
        targetBtn = UIButton()
        targetBtn.backgroundColor = .clear
        targetBtn.setTitle("（目标" + String(minute) + "分钟）>", for: .normal)
        targetBtn.setTitleColor(.black, for: .normal)
        targetBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        targetBtn.titleLabel?.textAlignment = .center
        self.contentView.addSubview(targetBtn)
        targetBtn.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.top.equalTo(timeLabel.snp.bottom).offset(10)
        }
        
        goStoreBtn = UIButton()
        goStoreBtn.backgroundColor = .clear
        goStoreBtn.setTitle("搜索图书商店", for: .normal)
        goStoreBtn.setTitleColor(.white, for: .normal)
        goStoreBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        goStoreBtn.backgroundColor = .black
        goStoreBtn.layer.cornerRadius = 25
        self.contentView.addSubview(goStoreBtn)
        goStoreBtn.snp.makeConstraints { (make) in
            make.width.equalTo(300)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.top.equalTo(targetBtn.snp.bottom).offset(20)
        }
    }
    
    @objc private func targetChanged() {
        minute = UserDefaults.standard.integer(forKey: GTUserDefaultKeys.EveryDayReadTarget.target)
        let finishMinute = minute - totalMinTime
        targetBtn.setTitle("（目标" + String(minute) + "分钟）>", for: .normal)
        subTitleTowLabel.text = "还需" + String(finishMinute <= 0 ? 0 : finishMinute) + "分钟"
        progressView.setProgress(CGFloat(totalMinTime >= minute ? minute : totalMinTime) / CGFloat(minute))
    }
    
    // 更新数据
    func updateWithData(model: GTAnalyseDataModel) {
        totalMinTime = 0
        
        for index in 0..<model.timeLists!.count {
            totalMinTime += model.timeLists![index]
        }
        
        // 设置时间格式
        var minTxt = ""
        var hourTxt = ""
        let min = totalMinTime % 60
        if min < 10 {
            minTxt = "0" + String(min)
        } else {
            minTxt = String(min)
        }
        let hour = (totalMinTime - min) / 60 % 60
        hourTxt = String(hour)

        timeLabel.text = hourTxt + ":" + minTxt
        
        self.targetChanged()
    }
}
