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
    var thisReadBehaviourView: GTReadBehaviourView!
    
    var dataModel: GTAnalyseDataModel?
    let viewCornerRadius = 16.0
    let kGTScreenWidth = UIScreen.main.bounds.width
    
    lazy var analyseScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor(hexString: "#f2f2f7")
        scrollView.showsVerticalScrollIndicator = true
        scrollView.bounces = true
        scrollView.isScrollEnabled = true
        scrollView.delegate = self
        
        return scrollView
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
        analyseScrollView.mj_header = header
        analyseScrollView.mj_header?.beginRefreshing()
        self.view.addSubview(analyseScrollView)
        analyseScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(75)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        oneDayReadTimeView = GTReadTimeView()
        oneDayReadTimeView.layer.cornerRadius = viewCornerRadius
        self.analyseScrollView.addSubview(oneDayReadTimeView)
        oneDayReadTimeView.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.centerX.equalToSuperview()
            make.height.equalTo(400)
        }
        
        thisReadTimeView = GTThisReadDataView(titleTxt: "本次阅读时间", dataTxt: "0时0分", imgName: "this_time")
        thisReadTimeView.layer.cornerRadius = viewCornerRadius
        self.analyseScrollView.addSubview(thisReadTimeView)
        thisReadTimeView.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 - 3.0 * thisTimeReadDataCellMargin) / 4.0)
            make.top.equalTo(oneDayReadTimeView.snp.bottom).offset(32)
        }
        
        thisReadConcentrationView = GTThisReadDataView(titleTxt: "本次阅读专注度", dataTxt: "0%", imgName: "this_concentration")
        thisReadConcentrationView.layer.cornerRadius = viewCornerRadius
        self.analyseScrollView.addSubview(thisReadConcentrationView)
        thisReadConcentrationView.snp.makeConstraints { (make) in
            make.left.equalTo(thisReadTimeView.snp.right).offset(thisTimeReadDataCellMargin)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 - 3.0 * thisTimeReadDataCellMargin) / 4.0)
            make.top.equalTo(thisReadTimeView.snp.top)
        }
        
        thisReadLineView = GTThisReadDataView(titleTxt: "本次阅读行数", dataTxt: "0", imgName: "this_line")
        thisReadLineView.layer.cornerRadius = viewCornerRadius
        self.analyseScrollView.addSubview(thisReadLineView)
        thisReadLineView.snp.makeConstraints { (make) in
            make.left.equalTo(thisReadConcentrationView.snp.right).offset(thisTimeReadDataCellMargin)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 - 3.0 * thisTimeReadDataCellMargin) / 4.0)
            make.top.equalTo(thisReadTimeView.snp.top)
        }
        
        thisReadPageView = GTThisReadDataView(titleTxt: "本次阅读页数", dataTxt: "0", imgName: "this_page")
        thisReadPageView.layer.cornerRadius = viewCornerRadius
        self.analyseScrollView.addSubview(thisReadPageView)
        thisReadPageView.snp.makeConstraints { (make) in
            make.left.equalTo(thisReadLineView.snp.right).offset(thisTimeReadDataCellMargin)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 - 3.0 * thisTimeReadDataCellMargin) / 4.0)
            make.top.equalTo(thisReadTimeView.snp.top)
        }
        
        thisReadSpeedView = GTReadSpeedView()
        thisReadSpeedView.layer.cornerRadius = viewCornerRadius
        self.analyseScrollView.addSubview(thisReadSpeedView)
        thisReadSpeedView.snp.makeConstraints { (make) in
            make.left.equalTo(oneDayReadTimeView.snp.left)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 -  32) / 2.0)
            make.top.equalTo(thisReadTimeView.snp.bottom).offset(32)
        }
        
        thisReadBehaviourView = GTReadBehaviourView()
        thisReadBehaviourView.layer.cornerRadius = viewCornerRadius
        self.analyseScrollView.addSubview(thisReadBehaviourView)
        thisReadBehaviourView.snp.makeConstraints { (make) in
            make.left.equalTo(thisReadLineView.snp.left)
            make.width.height.equalTo(thisReadSpeedView.snp.width)
            make.top.equalTo(thisReadSpeedView.snp.top)
        }
        
        self.analyseScrollView.updateContentView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.analyseScrollView.updateContentView()
    }
    
    // 下拉刷新操作
    @objc func refresh(refreshControl: UIRefreshControl) {
        GTNet.shared.getAnalyseData(failure: {json in
            refreshControl.endRefreshing()
            let alertController = UIAlertController(title: "请求数据失败", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "确定", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }) { json in
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            self.dataModel = try! decoder.decode(GTAnalyseDataModel.self, from: data!)
            
            self.oneDayReadTimeView.updateWithData(model: self.dataModel!)
            self.thisReadTimeView.updateWithData(text: String(self.dataModel?.thisTimeData.hour ?? 0) + "时" + String(self.dataModel?.thisTimeData.min ?? 0) + "分")
            self.thisReadConcentrationView.updateWithData(text: String(format: "%.2f", (self.dataModel?.thisTimeData.focus ?? 0) * 100) + "%")
            self.thisReadLineView.updateWithData(text: String(self.dataModel?.thisTimeData.rows ?? 0))
            self.thisReadPageView.updateWithData(text: String(self.dataModel?.thisTimeData.pages ?? 0))
            self.thisReadSpeedView.updateWithData(model: self.dataModel!)
            self.thisReadBehaviourView.updateWithData(model: self.dataModel!)
            
            refreshControl.endRefreshing()
        }
    }
}

extension UIScrollView {
    func updateContentView() {
        contentSize.height = subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY ?? contentSize.height
    }
}

extension GTAnalyseViewController: UIScrollViewDelegate {

}
