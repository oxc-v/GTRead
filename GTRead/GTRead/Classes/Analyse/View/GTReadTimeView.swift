//
//  GTTimeView.swift
//  GTRead
//
//  Created by Dev on 2021/9/22.
//

import UIKit
import Charts

class GTReadTimeView: UIView {

    var timeLabel: UILabel! // 时间
    var unitLabel: UILabel! // 时间单位
    var chartView: BarChartView! // 柱状图

    // 重新父类的init方法
    // 指定初始化器
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.blue
        
        // 总时间
        timeLabel = UILabel()
        timeLabel.textAlignment = .center
        timeLabel.font = timeLabel.font.withSize(100)
        timeLabel.textColor = UIColor.white
        timeLabel.text = "0"
        self.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(50)
        }
        
        // 时间单位
        unitLabel = UILabel()
        unitLabel.textAlignment = .center
        unitLabel.font = unitLabel.font.withSize(30)
        unitLabel.textColor = UIColor.white
        unitLabel.text = "小时"
        self.addSubview(unitLabel)
        unitLabel.snp.makeConstraints { (make) in
            make.left.equalTo(timeLabel.snp.right).offset(5)
            make.top.equalTo(timeLabel.snp.bottom)
        }

        // 柱状图
        chartView = BarChartView()
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        chartView.xAxis.enabled = false
        chartView.legend.enabled = false
        chartView.dragEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.doubleTapToZoomEnabled = false
        self.addSubview(chartView)
        chartView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(300)
            make.bottom.equalToSuperview()
        }

    }
    
    // 更新数据
    func updateChartWithData(model: GTReadTimeModel) {
        var dataEntries = [BarChartDataEntry]()
        var totalTime = 0.0
        
        print(model.lists.count)
        
        for index in 0..<model.lists.count {
            let entry = BarChartDataEntry(x: Double(index), y: model.lists[index].min)
            dataEntries.append(entry)
            totalTime += model.lists[index].min
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries)
        chartDataSet.colors = [.green]
        chartDataSet.valueFont = UIFont.systemFont(ofSize: 15)
        let chartData = BarChartData(dataSets: [chartDataSet])
        chartView.data = chartData
        
        timeLabel.text = String(totalTime / 24)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
