//
//  GTTimeView.swift
//  GTRead
//
//  Created by Dev on 2021/9/22.
//

import UIKit

class GTReadTimeView: UIView {

    var titleLabel: UILabel!
    var subTitleLabel: UILabel!
    var titleTwoLabel: UILabel!
    var subTitleTowLabel: UILabel!
    var timeLabel: UILabel!
    var targetButton: UIButton!
    var goStoreButton: UIButton!
    var progressView: GTCircleProgressView!
    var totalMinTime = 0
    var minute = UserDefaults.standard.integer(forKey: UserDefaultKeys.EveryDayReadTarget.target) == 0 ? 60 : UserDefaults.standard.integer(forKey: UserDefaultKeys.EveryDayReadTarget.target)

    // 重新父类的init方法
    // 指定初始化器
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.black
        titleLabel.text = "阅读目标"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 23)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(65)
        }
        
        subTitleLabel = UILabel()
        subTitleLabel.textAlignment = .center
        subTitleLabel.textColor = UIColor(hexString: "#b4b4b4")
        subTitleLabel.text = "找一本好书，设定一个目标，养成每天阅读的习惯。"
        subTitleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        self.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        progressView = GTCircleProgressView()
        self.addSubview(progressView)
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
        self.addSubview(titleTwoLabel)
        titleTwoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(subTitleLabel.snp.bottom).offset(80)
        }
        
        subTitleTowLabel = UILabel()
        subTitleTowLabel.textAlignment = .center
        subTitleTowLabel.textColor = UIColor(hexString: "#199dd7")
        subTitleTowLabel.text = "还需" + String(minute - totalMinTime <= 0 ? 0 : minute - totalMinTime) + "分钟"
        subTitleTowLabel.font = UIFont.systemFont(ofSize: 23)
        self.addSubview(subTitleTowLabel)
        subTitleTowLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleTwoLabel.snp.bottom).offset(10)
        }
        
        timeLabel = UILabel()
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.systemFont(ofSize: 75)
        timeLabel.textColor = UIColor.black
        timeLabel.text = "0:00"
        self.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(subTitleTowLabel.snp.bottom).offset(10)
        }
        
        targetButton = UIButton()
        targetButton.backgroundColor = .clear
        targetButton.setTitle("（目标" + String(minute) + "分钟）>", for: .normal)
        targetButton.setTitleColor(.black, for: .normal)
        targetButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        targetButton.titleLabel?.textAlignment = .center
        self.addSubview(targetButton)
        targetButton.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.top.equalTo(timeLabel.snp.bottom).offset(10)
        }
        
        goStoreButton = UIButton()
        goStoreButton.backgroundColor = .clear
        goStoreButton.setTitle("搜索图书商店", for: .normal)
        goStoreButton.setTitleColor(.white, for: .normal)
        goStoreButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        goStoreButton.backgroundColor = .black
        goStoreButton.layer.cornerRadius = 25
        self.addSubview(goStoreButton)
        goStoreButton.snp.makeConstraints { (make) in
            make.width.equalTo(300)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.top.equalTo(targetButton.snp.bottom).offset(20)
        }
        
        // 每日阅读目标改变通知
        NotificationCenter.default.addObserver(self, selector: #selector(targetChanged), name: .GTReadTargetChanged, object: nil)
    }
    
    @objc func targetChanged() {
        minute = UserDefaults.standard.integer(forKey: UserDefaultKeys.EveryDayReadTarget.target)
        let finishMinute = minute - totalMinTime
        targetButton.setTitle("（目标" + String(minute) + "分钟）>", for: .normal)
        subTitleTowLabel.text = "还需" + String(finishMinute <= 0 ? 0 : finishMinute) + "分钟"
        progressView.setProgress(CGFloat(totalMinTime >= minute ? minute : totalMinTime) / CGFloat(minute))
    }
    
    // 更新数据
    func updateWithData(model: GTAnalyseDataModel) {
        totalMinTime = 0
        
        if model.lists != nil {
            for index in 0..<model.lists!.count {
                totalMinTime += model.lists![index].min
            }
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
        
        targetChanged()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
