//
//  GTReadTimeTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/19.
//

import Foundation
import UIKit
import Charts

class GTReadTimeChartCollectionViewCell: UICollectionViewCell {
    
    private var chartView: BarChartView!
    private var titleLabel: UILabel!
    private var baseView: GTShadowView!
    private var imgView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupBarChartView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // BarChartView
    private func setupBarChartView() {

        baseView = GTShadowView(opacity: 0.1)
        baseView.backgroundColor = .white
        baseView.layer.cornerRadius = 20
        self.contentView.addSubview(baseView)
        baseView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        
        imgView = UIImageView()
        imgView.image = UIImage(named: "read_time")
        imgView.contentMode = .scaleAspectFill
        baseView.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.height.width.equalTo(40)
            make.left.top.equalTo(20)
        }
        
        titleLabel = UILabel()
        titleLabel.text = "阅读时间分布"
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        baseView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imgView.snp.bottom).offset(10)
            make.left.equalTo(imgView.snp.left)
        }
        
        chartView = BarChartView()
        let  leftFormatter = NumberFormatter()  // 自定義格式
        leftFormatter.positiveSuffix = " min"   // 數字字尾單位
        chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter.init(formatter: leftFormatter)
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawZeroLineEnabled = true
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false    // 隐藏label
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
        chartView.noDataText = "暂无数据"
        baseView.addSubview(chartView)
        chartView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(20)
            make.bottom.right.equalToSuperview().offset(-20)
        }
    }
    
    // 更新数据
    func updateWithData(model: GTAnalyseDataModel) {
        let chartData = BarChartData()
        var dataEntries = [BarChartDataEntry]()
        var i = 0
        for index in 0..<(model.timeLists!.count * 2) {
            if index % 2 == 0 {
                let entry = BarChartDataEntry(x: Double(index), y: Double(model.timeLists![i]))
                dataEntries.append(entry)
                i += 1
            } else {
                let entry = BarChartDataEntry(x: Double(index), y: Double(0))
                dataEntries.append(entry)
            }
            
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries)
        chartDataSet.colors = [UIColor(hexString: "#2ec9a4")]
        chartDataSet.drawValuesEnabled = false
        chartData.dataSets.append(chartDataSet)
        chartView.data = chartData
    }
}
