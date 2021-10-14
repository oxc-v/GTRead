//
//  GTReadViewController.swift
//  GTRead
//
//  Created by YangJie on 2021/3/22.
//

import UIKit
import PDFKit
import SceneKit
import ARKit

class GTReadViewController: EyeTrackViewController {
    
    //MARK: - 导航条
    var navgationBarHiddenStatu: Bool = true
    var thumbBtn: UIButton!     // 缩略图
    var outlineBtn: UIButton!   // 目录按钮
    var commentBtn: UIButton!   // 评论按钮
    var adjustSwitch: UISwitch! // 视线校准按钮
    
    //MARK: -PDF 相关
    private var pdfdocument: PDFDocument?
    let pdfURL: URL // pdf路径
    lazy var pdfView: PDFView = {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true, withViewOptions: [UIPageViewController.OptionsKey.interPageSpacing: 0])
        return pdfView
    }()
    
    //MARK: - 视线相关
    var eyeTrackController: EyeTrackController!
    var correctPoints = [CGPoint]()
    var trackView: UIImageView!
    var trackCorrectView: UIImageView!
    var trackCorrectViewPoints = [CGPoint]()
    var correctPointsSet = [[CGPoint]]()
    var sightDatas = Array<[String:Any]>()
    var sightPoint = CGPoint()
    var currentDate: TimeInterval!
    var getSightDataTimer: Timer!
    var sightDataModel = GTTrackCorrectModel()

    // 构造函数
    init(path: URL) {
        pdfURL = path
        super.init(nibName: nil, bundle: nil)
        GTBook.shared.currentPdfView = pdfView
        GTBook.shared.pdfURL = pdfURL
        
        // 定时收集视线数据
        getSightDataTimer = Timer(timeInterval:0.1, repeats: true) { timer in
            let date = Date.init()
            let timeStamp = date.timeIntervalSince1970
            let point = self.sightDataModel.getCorrectSightData(p: self.sightPoint)
            let sightData = ["x": point.x, "y": point.y, "timeStamp": String(timeStamp)] as [String : Any]
            self.sightDatas.append(sightData)
        }
        RunLoop.current.add(getSightDataTimer, forMode: .default)
    }
    
    // 退出阅读界面
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            getSightDataTimer.invalidate()
            
            if sightDatas.isEmpty == false {
                // 发送视线数据
                GTNet.shared.commitGazeTrackData(success: { (json) in
                    self.sightDatas.removeAll()
                }, startTime: currentDate, lists: sightDatas, pageNum: pdfdocument?.index(for: pdfView.currentPage!) ?? 0)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
        // 记录进入时间
        currentDate = Date.init().timeIntervalSince1970
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setupView() {
        // 导航条
        self.setupNavgationBar()
        
        // 视线
        self.setupGateTrackView()
        
        // pdf
        self.setupPdfView()
        
        // 视线校准
        self.showTrackAlertController()
        
        self.view.bringSubviewToFront(trackView)
        self.view.bringSubviewToFront(trackCorrectView)
    }
    
    func setupNavgationBar() {
        adjustSwitch = UISwitch()
        adjustSwitch.isOn = true
        adjustSwitch.addTarget(self, action: #selector(switchChangedValue), for: .valueChanged)
        
        thumbBtn = UIButton(type: .custom)
        thumbBtn.setImage(UIImage(named: "thumbnails"), for: .normal)
        thumbBtn.backgroundColor = UIColor.clear
        thumbBtn.addTarget(self, action: #selector(thumbButtonDidClicked), for: .touchUpInside)

        outlineBtn = UIButton(type: .custom)
        outlineBtn.setImage(UIImage(named: "outline"), for: .normal)
        outlineBtn.backgroundColor = UIColor.clear
        outlineBtn.addTarget(self, action: #selector(outlineButtonDidClicked), for: .touchUpInside)

        commentBtn = UIButton(type: .custom)
        commentBtn.setImage(UIImage(named: "comment"), for: .normal)
        commentBtn.backgroundColor = UIColor.clear
        commentBtn.addTarget(self, action: #selector(commentButtonDidClicked), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: commentBtn), UIBarButtonItem(customView: outlineBtn),UIBarButtonItem(customView: thumbBtn), UIBarButtonItem(customView: adjustSwitch)]
    }
    
    func setupPdfView() {
        self.view.addSubview(pdfView)
        pdfView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let document = PDFDocument(url: pdfURL)
        pdfView.document = document
        self.pdfdocument = document
        let page = document?.page(at: GTBook.shared.getCacheData())
        if let lastPage = page {
            pdfView.go(to: lastPage)
        }
        
        NotificationCenter.default.addObserver(self,selector: #selector(handlePageChange(notification:)), name: Notification.Name.PDFViewPageChanged, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(pdfViewTapEvent))
        pdfView.addGestureRecognizer(tap)
    }
    
    func setupGateTrackView(){
        trackView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        trackView.contentMode = .scaleAspectFill
        trackView.image = UIImage(named: "track_icon")
        trackView.isHidden = true
        self.view.addSubview(trackView)
        
        trackCorrectView = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        trackCorrectView.contentMode = .scaleToFill
        trackCorrectView.image = UIImage(named: "track_adjust")
        trackCorrectView.isHidden = true
        self.view.addSubview(trackCorrectView)
        
        // 获取机型的尺寸
        let deviceTypeString = Device.getDeviceType()
        let deviceType = DeviceType(rawValue: deviceTypeString)

        self.eyeTrackController = EyeTrackController(device: Device(type: deviceType ?? .iPad11), smoothingRange: 10, blinkThreshold: .infinity, isHidden: true)
        self.eyeTrackController.onUpdate = { [weak self] info in
            self?.trackView.isHidden = false
            let point = CGPoint(x: info?.centerEyeLookAtPoint.x ?? 0, y: info?.centerEyeLookAtPoint.y ?? 0)
            self?.sightPoint = point
            let correctPoint = self?.sightDataModel.getCorrectSightData(p: self?.sightPoint ?? CGPoint())
            if self?.sightDataModel.isCorrect == true {
                self?.trackView.center = correctPoint ?? CGPoint()
            } else {
                self?.trackView.center = point
            }
        }
        self.initialize(eyeTrack: eyeTrackController.eyeTrack)
        self.show()
    }
    
    // 视线校准提示框
    func showTrackAlertController() {
        var isFirstRunning = true
        self.getSightDataTimer.invalidate()
        self.correctPoints.removeAll()
        self.correctPointsSet.removeAll()
        
        self.trackCorrectViewPoints = [CGPoint(x: 24, y: 24), CGPoint(x: UIScreen.main.bounds.width - 24, y: 24), CGPoint(x: UIScreen.main.bounds.width - 24, y: UIScreen.main.bounds.height - 24), CGPoint(x: 24, y: UIScreen.main.bounds.height - 24)]
        let alertController = UIAlertController(title: "视线校准", message: "分别注视屏幕四个角的图标3秒", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "校准", style: UIAlertAction.Style.default) { (action: UIAlertAction!) -> Void in
            self.trackView.isHidden = false
            let timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer_1 in
                if isFirstRunning == false {
                    self.correctPointsSet.append(self.correctPoints)
                }
                if (self.trackCorrectViewPoints.isEmpty == true) {
                    timer_1.invalidate()
                    self.adjustSwitch.setOn(false, animated: true)
                    self.trackCorrectView.isHidden = true
                    let alertController = UIAlertController(title: "视线校准完毕", message: "", preferredStyle:UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default) { (action: UIAlertAction!) -> Void in
                        var points = [CGPoint]()
                        for i in 0..<self.correctPointsSet.count {
                            points.append(CGPoint(x: self.correctPointsSet[i].medianX(), y: self.correctPointsSet[i].medianY()))
                        }
                        self.sightDataModel.acceptPoints = points
                        self.sightDataModel.isCorrect = true
                        self.getSightDataTimer.fire()
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.correctPoints.removeAll()
                    self.trackCorrectView.center = self.trackCorrectViewPoints.first!
                    self.trackCorrectView.isHidden = false
                    self.trackCorrectViewPoints.removeFirst()
                    
                    if isFirstRunning == true {
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer_2 in
                            if timer_1.isValid == false {
                                timer_2.invalidate()
                            }
                            self.correctPoints.append(self.sightPoint)
                        }
                    }
                    isFirstRunning = false
                }
            }
            timer.fire()
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func pdfViewTapEvent() {
        navgationBarHiddenStatu = !navgationBarHiddenStatu
        self.navigationController?.setNavigationBarHidden(navgationBarHiddenStatu, animated: true)
    }

    
    //MARK: -缩略图
    @objc private func thumbButtonDidClicked() {
        navgationBarHiddenStatu = true
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20

        let width = (self.view.frame.width - 10 * 4) / 3
        let height = width * 1.5

        layout.itemSize = CGSize(width: width, height: height)
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)

        let thumbnailGridViewController = GTThumbnailGridViewController(collectionViewLayout: layout)
        thumbnailGridViewController.pdfDocument = self.pdfdocument
        thumbnailGridViewController.delegate = self
        self.navigationController?.pushViewController(thumbnailGridViewController, animated: true)
    }

    //MARK: -目录
    @objc private func outlineButtonDidClicked() {
        navgationBarHiddenStatu = true
        if let pdfoutline = self.pdfdocument?.outlineRoot {
            let oulineViewController = GTOulineTableviewController(style: UITableView.Style.plain)
            oulineViewController.pdfOutlineRoot = pdfoutline
            oulineViewController.delegate = self

            self.navigationController?.pushViewController(oulineViewController, animated: true)
        }
    }
    
    //MARK: -评论
    @objc private func commentButtonDidClicked() {
        navgationBarHiddenStatu = true
        let commentVC = GTCommentViewController()
        commentVC.pageNum = ((pdfdocument?.index(for: pdfView.currentPage!) ?? -1 ) + 1)
        self.addChild(commentVC)
        self.view.addSubview(commentVC.view)
        commentVC.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    // 翻页回调
    @objc private func handlePageChange(notification: Notification){
        // 每一次翻页都保存一次进度
        GTBook.shared.cacheData()
        
        // 记录进入时间
        currentDate = Date.init().timeIntervalSince1970

        GTNet.shared.commitGazeTrackData(success: { (json) in
            self.sightDatas.removeAll()
        }, startTime: currentDate, lists: sightDatas, pageNum: pdfdocument?.index(for: pdfView.currentPage!) ?? 0)
    }
    
    // 视线校准
    @objc private func switchChangedValue() {
        if adjustSwitch.isOn == true {
            showTrackAlertController()
        }
    }
}

extension GTReadViewController: GTThumbnailGridViewControllerDelegate {
    func thumbnailGridViewController(_ thumbnailGridViewController: GTThumbnailGridViewController, didSelectPage page: PDFPage) {
        pdfView.go(to: page)
    }
}

extension GTReadViewController: GTOulineTableviewControllerDelegate {
    func oulineTableviewController(_ oulineTableviewController: GTOulineTableviewController, didSelectOutline outline: PDFOutline) {
        let action = outline.action
        if let actiongoto = action as? PDFActionGoTo {
            pdfView.go(to: actiongoto.destination)
        }
    }
}

extension Array where Element == CGPoint {
    func medianX() -> Double {
        let sortedArray = sorted { a, b in
            return a.x < b.x
        }
        if count % 2 != 0 {
            return Double(sortedArray[count / 2].x)
        } else {
            return Double(sortedArray[count / 2].x + sortedArray[count / 2 - 1].x) / 2.0
        }
    }
    
    func medianY() -> Double {
        let sortedArray = sorted { a, b in
            return a.y < b.y
        }
        if count % 2 != 0 {
            return Double(sortedArray[count / 2].y)
        } else {
            return Double(sortedArray[count / 2].y + sortedArray[count / 2 - 1].y) / 2.0
        }
    }
}
