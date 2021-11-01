//
//  GTReadBehaviourView.swift
//  GTRead
//
//  Created by Dev on 2021/10/24.
//

import UIKit
import Charts

class GTReadBehaviourView: UIView {
    
    var chartView: ScatterChartView!
    var dataModel: GTAnalyseDataModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.layer.shadowRadius = 5
        self.layer.shadowOffset = CGSize(width: 3.0, height: -3.0)
        self.layer.shadowOpacity = 0.1
        
        chartView = ScatterChartView()
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.dragEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.animate(xAxisDuration: 1, yAxisDuration: 1)
        chartView.noDataText = "你今天还没有阅读书籍哟，赶快去阅读叭"
        
        self.addSubview(chartView)
        chartView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
    }
    
    // 清空数据
    func clearData() {
        chartView.clear()
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
