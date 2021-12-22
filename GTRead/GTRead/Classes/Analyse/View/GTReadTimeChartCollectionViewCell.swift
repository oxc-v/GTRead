//
//  GTReadTimeChartCollectionViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/19.
//

import Foundation
import UIKit
import Charts

class GTReadTimeChartCollectionViewCell: UICollectionViewCell {
    
    var titleLabel: UILabel!
    private var separatorView: UIView!
    private var chartView: BarChartView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
        }
        
        separatorView = UIView()
        separatorView.backgroundColor = UIColor(hexString: "#cacacc")
        self.contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.width.equalToSuperview()
        }
        
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
            make.top.equalTo(separatorView.snp.bottom).offset(20)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
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
