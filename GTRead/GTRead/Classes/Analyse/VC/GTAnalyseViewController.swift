//
//  GTAnalyseViewController.swift
//  GTRead
//
//  Created by Dev on 2021/9/22.
//

import UIKit
import MJRefresh

class GTAnalyseViewController: GTBaseViewController {
    var timeView: GTReadTimeView!
    var dataModel: GTReadTimeModel?
    
    lazy var analyseCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor(hexString: "#f2f2f7")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellName)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "分析"
        self.view.backgroundColor = UIColor.white
        
        let header = MJRefreshNormalHeader()
        header.setTitle("下拉刷新", for: .idle)
        header.setTitle("释放更新", for: .pulling)
        header.setTitle("正在刷新...", for: .refreshing)
        header.setRefreshingTarget(self, refreshingAction: #selector(refresh(refreshControl:)))
        analyseCollectionView.mj_header = header
        analyseCollectionView.mj_header?.beginRefreshing()
        self.view.addSubview(analyseCollectionView)
        analyseCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(75)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        timeView = GTReadTimeView()
        self.analyseCollectionView.addSubview(timeView)
        timeView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(500)
        }
    }
    
    // 下拉刷新操作
    @objc func refresh(refreshControl: UIRefreshControl) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        GTNet.shared.getReadTimeList(dayTime: dateFormatter.string(from: Date()), failure: { json in
            refreshControl.endRefreshing()
            let alertController = UIAlertController(title: "请求阅读数据失败", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "确定", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }, success: {json in
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            self.dataModel = try! decoder.decode(GTReadTimeModel.self, from: data!)
            self.timeView.updateChartWithData(model: self.dataModel!)
            
            refreshControl.endRefreshing()
        })
    }
}
