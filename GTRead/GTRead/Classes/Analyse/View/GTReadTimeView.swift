//
//  GTTimeView.swift
//  GTRead
//
//  Created by Dev on 2021/9/22.
//

import UIKit
import Charts

class GTReadTimeView: UIView {

    var txtLabel: UILabel!
    var timeLabel: UILabel! // 时间
    var chartView: BarChartView! // 柱状图

    // 重新父类的init方法
    // 指定初始化器
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        self.layer.shadowRadius = 5
        self.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        self.layer.shadowOpacity = 0.1
        
        // 提示语
        txtLabel = UILabel()
        txtLabel.textAlignment = .center
        txtLabel.textColor = UIColor.black
        txtLabel.text = "今日阅读进度"
        txtLabel.font = txtLabel.font.withSize(25)
        self.addSubview(txtLabel)
        txtLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(50)
        }
        
        // 时间
        timeLabel = UILabel()
        timeLabel.textAlignment = .center
        timeLabel.font = timeLabel.font.withSize(100)
        timeLabel.textColor = UIColor.black
        timeLabel.text = "0:00"
        self.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(txtLabel.snp.top).offset(20)
        }

        // 柱状图
        chartView = BarChartView()
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelCount = 12
        let xValues = ["2:00", "4:00", "6:00", "8:00", "10:00", "12:00", "14:00", "16:00", "18:00", "20:00", "22:00", "24:00"]
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xValues)
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.legend.enabled = false
        chartView.dragEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.animate(xAxisDuration: 1, yAxisDuration: 1)
        chartView.noDataText = "你今天还没有阅读书籍哟，赶快去阅读叭"
        
        self.addSubview(chartView)
        chartView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(timeLabel.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
        }
    }
    
    // 更新数据
    func updateWithData(model: GTAnalyseDataModel) {
        
        var totalMinTime = 0
        
        if model.lists != nil {
            let chartData = BarChartData()
            var dataEntries = [BarChartDataEntry]()
            for index in 0..<model.lists!.count {
                let entry = BarChartDataEntry(x: Double(index), y: Double(model.lists![index].min))
                dataEntries.append(entry)
                totalMinTime += model.lists![index].min
            }
            let chartDataSet = BarChartDataSet(entries: dataEntries)
            chartDataSet.colors = [UIColor(hexString: "#2ec9a4")]
            chartDataSet.drawValuesEnabled = false
            chartData.dataSets.append(chartDataSet)
            chartView.data = chartData
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
        if hour < 10 {
            hourTxt = "0" + String(hour)
        } else {
            hourTxt = String(hour)
        }
        timeLabel.text = hourTxt + ":" + minTxt
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
