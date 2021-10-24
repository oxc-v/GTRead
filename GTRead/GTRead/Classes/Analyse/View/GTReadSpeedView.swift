//
//  GTReadSpeedView.swift
//  GTRead
//
//  Created by Dev on 2021/10/19.
//

import UIKit
import Charts

class GTReadSpeedView: UIView {
    
    var chartView: LineChartView!
    var dataModel: GTAnalyseDataModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.layer.shadowRadius = 5
        self.layer.shadowOffset = CGSize(width: 3.0, height: -3.0)
        self.layer.shadowOpacity = 0.1
        
        chartView = LineChartView()
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.rightAxis.enabled = false
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.dragEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.noDataText = "你今天还没有阅读书籍哟，赶快去阅读叭"
        chartView.animate(xAxisDuration: 1, yAxisDuration: 1)
        
        self.addSubview(chartView)
        chartView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
    }
    
    // 更新数据
    func updateWithData(model: GTAnalyseDataModel) {
        //生成10条随机数据
        var dataEntries = [ChartDataEntry]()
        for i in 0..<model.speedPoints.count {
            let entry = ChartDataEntry.init(x: Double(i), y: Double(model.speedPoints[i].point))
            dataEntries.append(entry)
        }
        dataEntries.sort(by: { $0.x < $1.x })
        //这10条数据作为1根折线里的所有数据
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "阅读速度")
        
        //将线条颜色设置为橙色
        chartDataSet.colors = [.orange]
        
        //修改线条大小
        chartDataSet.lineWidth = 2
        
        chartDataSet.drawValuesEnabled = false
        
        //目前折线图只包括1根折线
        let chartData = LineChartData(dataSets: [chartDataSet])
            
        //设置散点图数据
        chartView.data = chartData
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
