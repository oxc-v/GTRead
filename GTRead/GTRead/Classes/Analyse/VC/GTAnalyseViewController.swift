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
    
    var thisReadTimeView: GTThisReadDataView!
    var thisReadLineView: GTThisReadDataView!
    var thisReadPageView: GTThisReadDataView!
    var thisReadConcentrationView: GTThisReadDataView!
    let thisTimeReadDataCellMargin = 32.0
    
    var thisReadSpeedView: GTReadSpeedView!
    var thisReadSpeedView1: GTReadSpeedView!
    
    var dataModel: GTReadTimeModel?
    let viewCornerRadius = 16.0
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
        self.view.backgroundColor = UIColor(hexString: "#f2f2f7")
        
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
        oneDayReadTimeView.layer.cornerRadius = viewCornerRadius
        self.analyseCollectionView.addSubview(oneDayReadTimeView)
        oneDayReadTimeView.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.centerX.equalToSuperview()
            make.height.equalTo(400)
        }
        
        thisReadTimeView = GTThisReadDataView(titleTxt: "本次阅读时间", dataTxt: "1时40分", imgName: "this_time")
        thisReadTimeView.layer.cornerRadius = viewCornerRadius
        self.analyseCollectionView.addSubview(thisReadTimeView)
        thisReadTimeView.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 - 3.0 * thisTimeReadDataCellMargin) / 4.0)
            make.top.equalTo(oneDayReadTimeView.snp.bottom).offset(32)
        }
        
        thisReadConcentrationView = GTThisReadDataView(titleTxt: "本次阅读专注度", dataTxt: "90%", imgName: "this_concentration")
        thisReadConcentrationView.layer.cornerRadius = viewCornerRadius
        self.analyseCollectionView.addSubview(thisReadConcentrationView)
        thisReadConcentrationView.snp.makeConstraints { (make) in
            make.left.equalTo(thisReadTimeView.snp.right).offset(thisTimeReadDataCellMargin)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 - 3.0 * thisTimeReadDataCellMargin) / 4.0)
            make.top.equalTo(thisReadTimeView.snp.top)
        }
        
        thisReadLineView = GTThisReadDataView(titleTxt: "本次阅读行数", dataTxt: "255", imgName: "this_line")
        thisReadLineView.layer.cornerRadius = viewCornerRadius
        self.analyseCollectionView.addSubview(thisReadLineView)
        thisReadLineView.snp.makeConstraints { (make) in
            make.left.equalTo(thisReadConcentrationView.snp.right).offset(thisTimeReadDataCellMargin)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 - 3.0 * thisTimeReadDataCellMargin) / 4.0)
            make.top.equalTo(thisReadTimeView.snp.top)
        }
        
        thisReadPageView = GTThisReadDataView(titleTxt: "本次阅读页数", dataTxt: "15", imgName: "this_page")
        thisReadPageView.layer.cornerRadius = viewCornerRadius
        self.analyseCollectionView.addSubview(thisReadPageView)
        thisReadPageView.snp.makeConstraints { (make) in
            make.left.equalTo(thisReadLineView.snp.right).offset(thisTimeReadDataCellMargin)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 - 3.0 * thisTimeReadDataCellMargin) / 4.0)
            make.top.equalTo(thisReadTimeView.snp.top)
        }
        
        thisReadSpeedView = GTReadSpeedView()
        thisReadSpeedView.layer.cornerRadius = viewCornerRadius
        self.analyseCollectionView.addSubview(thisReadSpeedView)
        thisReadSpeedView.snp.makeConstraints { (make) in
            make.left.equalTo(oneDayReadTimeView.snp.left)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 -  32) / 2.0)
            make.top.equalTo(thisReadTimeView.snp.bottom).offset(32)
        }
        
        thisReadSpeedView1 = GTReadSpeedView()
        thisReadSpeedView1.layer.cornerRadius = viewCornerRadius
        self.analyseCollectionView.addSubview(thisReadSpeedView1)
        thisReadSpeedView1.snp.makeConstraints { (make) in
            make.left.equalTo(thisReadLineView.snp.left)
            make.width.height.equalTo(thisReadSpeedView.snp.width)
            make.top.equalTo(thisReadSpeedView.snp.top)
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
        
        self.thisReadSpeedView.upThisReadSpeedWithData()
        self.thisReadSpeedView1.upThisReadSpeedWithData()
    }
}
