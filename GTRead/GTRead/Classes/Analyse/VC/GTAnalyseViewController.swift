//
//  GTAnalyseViewController.swift
//  GTRead
//
//  Created by Dev on 2021/9/22.
//

import UIKit
import MJRefresh
import SwiftyPickerPopover

class GTAnalyseViewController: GTBaseViewController {
    
    var loadNetworkView: GTNetWorkUnavailableView!
    var goLoginAndRegisterView: GTGoLoginAndRegisterView!
    
    var oneDayReadTimeView: GTReadTimeView!
    var oneDayReadTimeBarChartView: GTReadBarChartView!
    
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
        self.view.backgroundColor = .white
        
        loadNetworkView = GTNetWorkUnavailableView()
        loadNetworkView.isHidden = true
        self.view.addSubview(loadNetworkView)
        loadNetworkView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.width.equalTo(320)
        }

        goLoginAndRegisterView = GTGoLoginAndRegisterView()
        goLoginAndRegisterView.isHidden = true
        self.view.addSubview(goLoginAndRegisterView)
        goLoginAndRegisterView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.width.equalTo(320)
        }
        
        analyseScrollView.isHidden = true
        let header = MJRefreshNormalHeader()
        header.setTitle("下拉刷新", for: .idle)
        header.setTitle("释放更新", for: .pulling)
        header.setTitle("正在刷新...", for: .refreshing)
        header.setRefreshingTarget(self, refreshingAction: #selector(refresh(refreshControl:)))
        analyseScrollView.mj_header = header
        self.view.addSubview(analyseScrollView)
        analyseScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(-72)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        oneDayReadTimeView = GTReadTimeView()
        oneDayReadTimeView.targetButton.addTarget(self, action: #selector(targetButtonDidClicked), for: .touchUpInside)
        oneDayReadTimeView.goStoreButton.addTarget(self, action: #selector(goSearchViewController(sender:)), for: .touchUpInside)
        self.analyseScrollView.addSubview(oneDayReadTimeView)
        oneDayReadTimeView.snp.makeConstraints { (make) in
            make.centerX.left.right.top.equalToSuperview()
            make.height.equalTo(500)
        }
        
        oneDayReadTimeBarChartView = GTReadBarChartView()
        oneDayReadTimeBarChartView.layer.cornerRadius = viewCornerRadius
        self.analyseScrollView.addSubview(oneDayReadTimeBarChartView)
        oneDayReadTimeBarChartView.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(350)
            make.top.equalTo(oneDayReadTimeView.snp.bottom).offset(32)
        }
        
        thisReadTimeView = GTThisReadDataView(titleTxt: "本次阅读时间", dataTxt: "0时0分", imgName: "this_time")
        thisReadTimeView.layer.cornerRadius = viewCornerRadius
        self.analyseScrollView.addSubview(thisReadTimeView)
        thisReadTimeView.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 - 3.0 * thisTimeReadDataCellMargin) / 4.0)
            make.top.equalTo(oneDayReadTimeBarChartView.snp.bottom).offset(32)
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
            make.left.equalTo(16)
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
        
        // 重新加载网络
        NotificationCenter.default.addObserver(self, selector: #selector(getReadData), name: .GTLoadNetwork, object: nil)
        // 跳转个人主页
        NotificationCenter.default.addObserver(self, selector: #selector(goPersonalViewController), name: .GTGoPersonalViewController, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) == nil {
            self.goLoginAndRegisterView.isHidden = false
            self.loadNetworkView.isHidden = true
            self.analyseScrollView.isHidden = true
        } else if !GTNet.shared.networkAvailable() {
            self.loadNetworkView.isHidden = false
            self.goLoginAndRegisterView.isHidden = true
            self.analyseScrollView.isHidden = true
        } else {
            self.getReadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.analyseScrollView.updateContentView()
    }
    
    @objc func targetButtonDidClicked(sender: UIButton) {
        let popoverVC = GTMinutePickerViewController()
        let nav = UINavigationController(rootViewController: popoverVC)
        nav.modalPresentationStyle = .popover
        nav.preferredContentSize = CGSize(width: 220, height: 180)
        if let popoverController = nav.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = CGRect(x: sender.frame.size.width / 2.0, y: sender.frame.size.height, width: 0, height: 0)
            popoverController.permittedArrowDirections = .up
            popoverController.delegate = self
        }
        present(nav, animated: true, completion: nil)
    }
    
    // 跳转个人主页
    @objc private func goPersonalViewController() {
        self.tabBarController?.selectedIndex = 4
    }
    
    // 搜索页
    @objc private func goSearchViewController(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.2, completion: {_ in
            self.tabBarController?.selectedIndex = 2
        })
    }
    
    // 获取阅读数据
    @objc private func getReadData() {
        self.loadNetworkView.isHidden = true
        self.goLoginAndRegisterView.isHidden = true
        self.showActivityIndicatorView()
        self.refresh(refreshControl: nil)
    }
    
    // 下拉刷新操作
    @objc func refresh(refreshControl: UIRefreshControl?) {
        GTNet.shared.getAnalyseData(failure: {json in
            refreshControl?.endRefreshing()
            self.hideActivityIndicatorView()
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
            
            self.loadNetworkView.isHidden = false
            self.goLoginAndRegisterView.isHidden = true
            self.analyseScrollView.isHidden = true
        }) { json in
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            self.dataModel = try? decoder.decode(GTAnalyseDataModel.self, from: data!)
            if self.dataModel == nil {
                self.showNotificationMessageView(message: "服务器数据错误")
            } else if self.dataModel!.status.code == -1 {
                self.updateWithData(model: self.dataModel!)
            } else {
                self.updateWithData(model: self.dataModel!)
            }
            self.analyseScrollView.isHidden = false
            
            self.hideActivityIndicatorView()
            refreshControl?.endRefreshing()
        }
        
        // 获取每日阅读目标
        GTNet.shared.getReadTarget(failure: {json in
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
        }) { json in
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            let dataModel = try? decoder.decode(GTReadTargetDataModel.self, from: data!)
            if dataModel == nil {
                self.showNotificationMessageView(message: "服务器数据错误")
            } else if dataModel?.minute != 0 {
                // 保存阅读目标
                UserDefaults.standard.set(dataModel?.minute, forKey: UserDefaultKeys.EveryDayReadTarget.target)
                // 每日阅读目标改变通知
                NotificationCenter.default.post(name: .GTReadTargetChanged, object: self)
            }
        }
    }
    
    // 更新数据
    func updateWithData(model: GTAnalyseDataModel) {
        self.oneDayReadTimeView.updateWithData(model: model)
        self.thisReadTimeView.updateWithData(text: String(model.thisTimeData?.hour ?? 0) + "时" + String(model.thisTimeData?.min ?? 0) + "分")
        self.thisReadConcentrationView.updateWithData(text: String(format: "%.2f", (model.thisTimeData?.focus ?? 0) * 100) + "%")
        self.thisReadLineView.updateWithData(text: String(model.thisTimeData?.rows ?? 0))
        self.thisReadPageView.updateWithData(text: String(model.thisTimeData?.pages ?? 0))
        self.thisReadSpeedView.updateWithData(model: model)
        self.thisReadBehaviourView.updateWithData(model: model)
        self.oneDayReadTimeBarChartView.updateWithData(model: model)
    }
}

extension GTAnalyseViewController: UIPopoverPresentationControllerDelegate {
    
}

extension GTAnalyseViewController: UIScrollViewDelegate {

}
