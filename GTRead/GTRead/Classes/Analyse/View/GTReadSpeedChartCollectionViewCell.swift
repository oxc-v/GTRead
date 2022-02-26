//
//  GTReadChartCollectionViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/19.
//

import Foundation
import UIKit
import Charts

class GTReadSpeedChartCollectionViewCell: UICollectionViewCell {
    
    private var titleLabel: UILabel!
    private var chartView: LineChartView!
    private var baseView: GTShadowView!
    private var imgView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        baseView = GTShadowView(opacity: 0.1)
        baseView.backgroundColor = .white
        baseView.layer.cornerRadius = 20
        self.contentView.addSubview(baseView)
        baseView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        
        imgView = UIImageView()
        imgView.image = UIImage(named: "read_speed")
        imgView.contentMode = .scaleAspectFill
        baseView.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.height.width.equalTo(40)
            make.left.top.equalTo(20)
        }
        
        titleLabel = UILabel()
        titleLabel.text = "阅读速度"
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        baseView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imgView.snp.bottom).offset(10)
            make.left.equalTo(imgView.snp.left)
        }
        
        chartView = LineChartView()
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawZeroLineEnabled = true
        chartView.leftAxis.enabled = true
        chartView.legend.enabled = false    // 隐藏label
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.dragEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.noDataText = "暂无数据"
        chartView.animate(xAxisDuration: 1, yAxisDuration: 1)
        baseView.addSubview(chartView)
        chartView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(20)
            make.bottom.right.equalToSuperview().offset(-20)
        }
    }
    
    // 更新数据
    func updateWithData(model: GTAnalyseDataModel) {
        let chartData = LineChartData()

        var dataEntries = [ChartDataEntry]()
        for i in 0..<model.speedPoints!.count {
            let entry = ChartDataEntry.init(x: Double(i), y: Double(model.speedPoints![i]))
            dataEntries.append(entry)
        }
        dataEntries.sort(by: { $0.x < $1.x })
        //这10条数据作为1根折线里的所有数据
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "阅读速度")

        //将线条颜色设置为橙色
        chartDataSet.colors = [UIColor(hexString: "#5950c5")]

        //修改线条大小
        chartDataSet.lineWidth = 2

        chartDataSet.drawValuesEnabled = false

        //目前折线图只包括1根折线
        chartData.dataSets.append(chartDataSet)
        //设置散点图数据
        chartView.data = chartData
    }
}
