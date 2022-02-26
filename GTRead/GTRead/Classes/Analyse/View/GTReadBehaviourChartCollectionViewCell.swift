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
    
    private var titleLabel: UILabel!
    private var chartView: PieChartView!
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
        imgView.image = UIImage(named: "read_state")
        imgView.contentMode = .scaleAspectFill
        baseView.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.height.width.equalTo(40)
            make.left.top.equalTo(20)
        }

        titleLabel = UILabel()
        titleLabel.text = "学习状态"
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        baseView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imgView.snp.bottom).offset(10)
            make.left.equalTo(imgView.snp.left)
        }
        
        chartView = PieChartView()
        chartView.animate(xAxisDuration: 1, yAxisDuration: 1)
        chartView.noDataText = "暂无数据"
        baseView.addSubview(chartView)
        chartView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(20)
            make.bottom.right.equalToSuperview().offset(-20)
        }
    }
    
    // 更新数据
    func updateWithData(model: GTAnalyseDataModel) {
        
        var dataEntries = [PieChartDataEntry]()
        for item in model.pipChart! {
            let entry = PieChartDataEntry(value: Double(item.Percentage), label: item.behavior)
            dataEntries.append(entry)
        }
        let chartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        
        //设置颜色
        chartDataSet.colors = [UIColor(hexString: "#258cf6"), UIColor(hexString: "#2ec9a4"), UIColor(hexString: "#5950c5")]
            
        chartDataSet.yValuePosition = .outsideSlice //数值显示在外
            
        let chartData = PieChartData(dataSet: chartDataSet)
        chartData.setValueTextColor(.black)//文字颜色为黑色
            
        //设置饼状图数据
        chartView.data = chartData
    }
}
