//
//  GTReadBarChartView.swift
//  GTRead
//
//  Created by Dev on 2021/11/9.
//

import Foundation
import Charts
import UIKit

class GTReadBarChartView: UIView {
    
    var chartView: BarChartView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        // 柱状图
        chartView = BarChartView()
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawZeroLineEnabled = true
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelCount = 24
        let xValues = [" ", "2:00", " ", "4:00", " ", "6:00", " ", "8:00", " ", "10:00", " ", "12:00", " ", "14:00", " ", "16:00", " ", "18:00", " ", "20:00", " ", "22:00", " ",  "24:00"]
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xValues)
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.dragEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.leftAxis.axisMinimum = 0
        chartView.animate(xAxisDuration: 1, yAxisDuration: 1)
        chartView.noDataText = "你今天还没有阅读书籍哟，赶快去阅读叭"
        
        self.addSubview(chartView)
        chartView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(16)
            make.right.bottom.equalToSuperview().offset(-16)
        }
    }
    
    // 更新数据
    func updateWithData(model: GTAnalyseDataModel) {
        if model.lists != nil {
            let chartData = BarChartData()
            var dataEntries = [BarChartDataEntry]()
            var i = 0
            for index in 0..<(model.lists!.count * 2) {
                if index % 2 == 0 {
                    let entry = BarChartDataEntry(x: Double(index), y: Double(model.lists![i].min))
                    dataEntries.append(entry)
                    i += 1
                } else {
                    let entry = BarChartDataEntry(x: Double(index), y: Double(0))
                    dataEntries.append(entry)
                }
                
            }
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: "阅读时段分布")
            chartDataSet.colors = [UIColor(hexString: "#2ec9a4")]
            chartDataSet.drawValuesEnabled = false
            chartData.dataSets.append(chartDataSet)
            chartView.data = chartData
        } else {
            chartView.clear()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
