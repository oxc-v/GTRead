//
//  GTReadBehaviourChartCollectionViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/19.
//

import Foundation
import UIKit
import Charts

class GTReadBehaviourChartCollectionViewCell: UICollectionViewCell {
    
    var titleLabel: UILabel!
    private var separatorView: UIView!
    private var chartView: ScatterChartView!
    
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
        
        chartView = ScatterChartView()
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawZeroLineEnabled = true
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.dragEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.animate(xAxisDuration: 1, yAxisDuration: 1)
        chartView.noDataText = "你今天还没有阅读书籍哟，赶快去阅读叭"
        self.contentView.addSubview(chartView)
        chartView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(20)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    // 更新数据
    func updateWithData(model: GTAnalyseDataModel) {
        if model.scatterDiagram != nil {
            let chartData =  ScatterChartData()
            for i in 0..<model.scatterDiagram!.count {
                var dataEntries = [ChartDataEntry]()
                for j in 0..<model.scatterDiagram![i].locate.count {
                    let entry = ChartDataEntry.init(x: Double(model.scatterDiagram![i].locate[j].x), y: Double(model.scatterDiagram![i].locate[j].y))
                    dataEntries.append(entry)
                }
                dataEntries.sort(by: { $0.x < $1.x })
                let chartDataSet = ScatterChartDataSet(entries: dataEntries, label: model.scatterDiagram![i].action)
                
                // 线条颜色
                chartDataSet.colors = [UIColor(hexString: model.scatterDiagram![i].color)]
                
                // 散点样式
                chartDataSet.setScatterShape(.circle)
                
                chartDataSet.drawValuesEnabled = false
                
                chartData.dataSets.append(chartDataSet)
            }
            // 设置散点图数据
            chartView.data = chartData
        } else {
            chartView.clear()
        }
    }
}
