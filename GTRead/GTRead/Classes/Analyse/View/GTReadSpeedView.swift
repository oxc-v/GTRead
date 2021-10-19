//
//  GTReadSpeedView.swift
//  GTRead
//
//  Created by Dev on 2021/10/19.
//

import UIKit
import Charts

class GTReadSpeedView: UIView {
    
    var chartView: ScatterChartView!
    
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
        
        chartView.noDataText = "你今天还没有阅读书籍哟，赶快去阅读叭"
        
        self.addSubview(chartView)
        chartView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
    }
    
    // 更新数据
    func upThisReadSpeedWithData() {
        let dataEntries1 = (0..<100).map { (i) -> ChartDataEntry in
            let val = Double(arc4random_uniform(100) + 3)
            return ChartDataEntry(x: Double(i), y: val)
        }
        let chartDataSet1 = ScatterChartDataSet(entries: dataEntries1, label: "阅读速度")
        chartDataSet1.setScatterShape(.circle)
        chartDataSet1.setColor(UIColor(hexString: "#2ec9a4"))
        
        //目前散点图包括2组数据
        let chartData = ScatterChartData(dataSets: [chartDataSet1])
            
        //设置散点图数据
        chartView.data = chartData
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
