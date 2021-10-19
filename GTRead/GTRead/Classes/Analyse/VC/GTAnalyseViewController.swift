//
//  GTAnalyseViewController.swift
//  GTRead
//
//  Created by Dev on 2021/9/22.
//

import UIKit
import MJRefresh

class GTAnalyseViewController: GTBaseViewController {
    
    var oneDayReadTimeView: GTReadTimeView!
    
    var thisReadTimeView: GTReadThisReadDataView!
    var thisReadLineView: GTReadThisReadDataView!
    var thisReadPageView: GTReadThisReadDataView!
    var thisReadConcentrationView: GTReadThisReadDataView!
    let thisTimeReadDataCellMargin = 32.0
    let thisTimeReadDataCellCornerRadius = 16.0
    
    var dataModel: GTReadTimeModel?
    let kGTScreenWidth = UIScreen.main.bounds.width
    
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
        
        oneDayReadTimeView = GTReadTimeView()
        self.analyseCollectionView.addSubview(oneDayReadTimeView)
        oneDayReadTimeView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(400)
        }
        
        thisReadTimeView = GTReadThisReadDataView(titleTxt: "本次阅读时间", dataTxt: "1时40分", imgName: "this_time")
        thisReadTimeView.layer.cornerRadius = thisTimeReadDataCellCornerRadius
        self.analyseCollectionView.addSubview(thisReadTimeView)
        thisReadTimeView.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 - 3.0 * thisTimeReadDataCellMargin) / 4.0)
            make.top.equalTo(oneDayReadTimeView.snp.bottom).offset(32)
        }
        
        thisReadConcentrationView = GTReadThisReadDataView(titleTxt: "本次阅读专注度", dataTxt: "90%", imgName: "this_concentration")
        thisReadConcentrationView.layer.cornerRadius = thisTimeReadDataCellCornerRadius
        self.analyseCollectionView.addSubview(thisReadConcentrationView)
        thisReadConcentrationView.snp.makeConstraints { (make) in
            make.left.equalTo(thisReadTimeView.snp.right).offset(thisTimeReadDataCellMargin)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 - 3.0 * thisTimeReadDataCellMargin) / 4.0)
            make.top.equalTo(thisReadTimeView.snp.top)
        }
        
        thisReadPageView = GTReadThisReadDataView(titleTxt: "本次阅读行数", dataTxt: "255", imgName: "this_line")
        thisReadPageView.layer.cornerRadius = thisTimeReadDataCellCornerRadius
        self.analyseCollectionView.addSubview(thisReadPageView)
        thisReadPageView.snp.makeConstraints { (make) in
            make.left.equalTo(thisReadConcentrationView.snp.right).offset(thisTimeReadDataCellMargin)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 - 3.0 * thisTimeReadDataCellMargin) / 4.0)
            make.top.equalTo(thisReadTimeView.snp.top)
        }
        
        thisReadLineView = GTReadThisReadDataView(titleTxt: "本次阅读页数", dataTxt: "15", imgName: "this_page")
        thisReadLineView.layer.cornerRadius = thisTimeReadDataCellCornerRadius
        self.analyseCollectionView.addSubview(thisReadLineView)
        thisReadLineView.snp.makeConstraints { (make) in
            make.left.equalTo(thisReadPageView.snp.right).offset(thisTimeReadDataCellMargin)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 - 3.0 * thisTimeReadDataCellMargin) / 4.0)
            make.top.equalTo(thisReadTimeView.snp.top)
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
            self.oneDayReadTimeView.updateChartWithData(model: self.dataModel!)
            
            refreshControl.endRefreshing()
        })
    }
}
