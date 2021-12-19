//
//  GTReadTimeTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/19.
//

import Foundation
import UIKit
import Charts

class GTReadTimeTableViewCell: UITableViewCell {
    
    private var chartView: BarChartView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupBarChartView()
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // BarChartView
    private func setupBarChartView() {

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
        chartView.noDataText = "一寸光阴一寸金，寸金难买寸光阴"
        
        self.contentView.addSubview(chartView)
        chartView.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
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
}
