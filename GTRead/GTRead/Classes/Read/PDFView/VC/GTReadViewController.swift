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
    var navgationBarHiddenStatu: Bool = false
    var thumbBtn: UIButton!     // 缩略图
    var oulineBtn: UIButton!   // 目录按钮
    var commentBtn: UIButton!   // 评论按钮
    var adjustBtn: UIButton! // 视线校准按钮
    var eyeBtn: UIButton!   // 视线图标按钮
    
    //MARK: -PDF 相关
    private var pdfdocument: PDFDocument?
    let pdfURL: URL // pdf路径
    var currentPage = 0
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
    var trackPointLabel: UILabel!
    var trackCorrectView: UIImageView!
    var trackCorrectViewPoints = [CGPoint]()
    var correctPointsSet = [[CGPoint]]()
    var sightDatas = Array<[String:Any]>()
    var sightPoint = CGPoint()
    var currentDate: TimeInterval!
    var getSightDataTimer: Timer!
    var sightDataModel = GTTrackCorrectModel()
    var bookId: String
    
    init(path: URL, bookId: String) {
        
        pdfURL = path
        self.bookId = bookId
        super.init(nibName: nil, bundle: nil)

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
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            getSightDataTimer.invalidate()
            // 发送视线数据
            if sightDatas.isEmpty == false {
                GTNet.shared.commitGazeTrackData(success: { (json) in
                    self.sightDatas.removeAll()
                }, startTime: currentDate, lists: sightDatas, bookId: self.bookId, pageNum: pdfdocument?.index(for: pdfView.currentPage!) ?? 0)
            }
            
            // 缓存PDF当前页码
            GTBookCache.shared.cacheBookPage(page: self.currentPage)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(self.navgationBarHiddenStatu, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newBackButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: #selector(newBackButtonDidClicked))
        newBackButton.image = UIImage(named: "navigation_back")
        self.navigationItem.leftBarButtonItem = newBackButton
        
        self.setupView()
        
        // 记录进入时间
        currentDate = Date.init().timeIntervalSince1970
        
        // 跳转PDF
        NotificationCenter.default.addObserver(self, selector: #selector(goPDFViewForOuline(notification:)), name: .GTGoPDFViewForPage, object: nil)
    }
    
    // 自定义页面退出操作
    @objc private func newBackButtonDidClicked() {
        if self.presentationController != nil {
            self.dismiss(animated: false, completion: {
                self.navigationController?.popToRootViewController(animated: true)
            })
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func setupView() {
        // 视线
        self.setupGateTrackView()
        
        // pdf
        self.setupPdfView()
        
        // 导航条
        self.setupNavgationBar()
                
        self.view.bringSubviewToFront(trackView)
        self.view.bringSubviewToFront(trackCorrectView)
    }
    
    func setupNavgationBar() {
        eyeBtn = UIButton(type: .custom)
        eyeBtn.setImage(UIImage(named: "track_show"), for: .normal)
        eyeBtn.backgroundColor = .clear
        eyeBtn.addTarget(self, action: #selector(eyeButtonDidClicked), for: .touchUpInside)
        
        adjustBtn = UIButton()
        adjustBtn.backgroundColor = .clear
        adjustBtn.setImage(UIImage(named: "adjust_btn"), for: .normal)
        adjustBtn.addTarget(self, action: #selector(adjustButtonDidClicked), for: .touchUpInside)
        
        thumbBtn = UIButton(type: .custom)
        thumbBtn.setImage(UIImage(named: "thumbnails"), for: .normal)
        thumbBtn.backgroundColor = UIColor.clear
        thumbBtn.addTarget(self, action: #selector(thumbButtonDidClicked), for: .touchUpInside)

        oulineBtn = UIButton(type: .custom)
        oulineBtn.setImage(UIImage(named: "ouline"), for: .normal)
        oulineBtn.backgroundColor = UIColor.clear
        oulineBtn.addTarget(self, action: #selector(outlineButtonDidClicked(sender:)), for: .touchUpInside)

        commentBtn = UIButton(type: .custom)
        commentBtn.setImage(UIImage(named: "comment"), for: .normal)
        commentBtn.backgroundColor = UIColor.clear
        commentBtn.addTarget(self, action: #selector(commentButtonDidClicked), for: .touchUpInside)
        
        // 判断PDF是否有目录
        if self.pdfdocument?.outlineRoot == nil {
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: adjustBtn), UIBarButtonItem(customView: eyeBtn), UIBarButtonItem(customView: commentBtn), UIBarButtonItem(customView: thumbBtn)]
        } else {
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: adjustBtn), UIBarButtonItem(customView: eyeBtn), UIBarButtonItem(customView: commentBtn), UIBarButtonItem(customView: thumbBtn), UIBarButtonItem(customView: oulineBtn)]
        }
    }
    
    func setupPdfView() {
        self.view.addSubview(pdfView)
        pdfView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let document = PDFDocument(url: pdfURL)
        pdfView.document = document
        self.pdfdocument = document
        self.currentPage = GTBookCache.shared.getCacheBookPage(bookId: self.bookId)
        let page = document?.page(at: self.currentPage)
        pdfView.go(to: page!)

        NotificationCenter.default.addObserver(self,selector: #selector(handlePageChange(notification:)), name: Notification.Name.PDFViewPageChanged, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(pdfViewTapEvent))
        pdfView.addGestureRecognizer(tap)
    }
    
    func setupGateTrackView() {
        trackView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        trackView.contentMode = .scaleAspectFill
        trackView.image = UIImage(named: "track_icon")
        trackView.isHidden = false
        self.view.addSubview(trackView)
        
        trackPointLabel = UILabel()
        trackPointLabel.textAlignment = .center
        trackPointLabel.font = UIFont.systemFont(ofSize: 15)
        self.trackView.addSubview(trackPointLabel)
        trackPointLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(10)
            make.width.equalTo(200)
        }
        
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
            let point = CGPoint(x: info?.centerEyeLookAtPoint.x ?? 0, y: info?.centerEyeLookAtPoint.y ?? 0)
            self?.sightPoint = point
            let correctPoint = self?.sightDataModel.getCorrectSightData(p: self?.sightPoint ?? CGPoint())
            if self?.sightDataModel.isCorrect == true {
                self?.trackView.center = correctPoint ?? CGPoint()
                self?.trackPointLabel.text = String(format: "%.2f", Double(correctPoint!.x)) + "，" + String(format: "%.2f", Double(correctPoint!.y))
            } else {
                self?.trackView.center = point
                self?.trackPointLabel.text = String(format: "%.2f", Double(point.x)) + "，" + String(format: "%.2f", Double(point.y))
            }
        }
        self.initialize(eyeTrack: eyeTrackController.eyeTrack)
        self.show()
    }
    
    // 跳转PDF
    @objc private func goPDFViewForOuline(notification: Notification) {
        self.dismiss(animated: true)
        if let ouline = notification.userInfo?["ouline"] as? PDFOutline {
            let action = ouline.action
            if let actiongoto = action as? PDFActionGoTo {
                pdfView.go(to: actiongoto.destination)
            }
        }
    }
    
    // 视线校准提示框
    func showTrackAlertController() {
        var isFirstRunning = true
        self.getSightDataTimer.fireDate = Date.distantFuture
        self.correctPoints.removeAll()
        self.correctPointsSet.removeAll()
        
        self.trackCorrectViewPoints = [CGPoint(x: 24, y: 24), CGPoint(x: UIScreen.main.bounds.width - 24, y: 24), CGPoint(x: UIScreen.main.bounds.width - 24, y: UIScreen.main.bounds.height - 24), CGPoint(x: 24, y: UIScreen.main.bounds.height - 24)]
        let alertController = UIAlertController(title: "视线校准", message: "依次注视屏幕四个角的图标3秒", preferredStyle: UIAlertController.Style.alert)
        let canncelAction = UIAlertAction(title: "取消", style: .cancel, handler: {_ in
            self.adjustBtn.isEnabled = true
        })
        let okAction = UIAlertAction(title: "校准", style: .default) { (action: UIAlertAction!) -> Void in
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
            let timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer_1 in
                if isFirstRunning == false {
                    self.correctPointsSet.append(self.correctPoints)
                }
                if (self.trackCorrectViewPoints.isEmpty == true) {
                    timer_1.invalidate()
                    self.trackCorrectView.isHidden = true
                    let alertController = UIAlertController(title: "视线校准完毕", message: "", preferredStyle:UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default) { (action: UIAlertAction!) -> Void in
                        
                        self.adjustBtn.isEnabled = true
                        
                        var points = [CGPoint]()
                        for i in 0..<self.correctPointsSet.count {
                            points.append(CGPoint(x: self.correctPointsSet[i].medianX(), y: self.correctPointsSet[i].medianY()))
                        }
                        
                        self.sightDataModel.acceptPoints = points
                        self.sightDataModel.isCorrect = true
                        self.getSightDataTimer.fireDate = Date.init(timeIntervalSinceNow: 0)
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
        
        alertController.addAction(canncelAction)
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
        self.present(thumbnailGridViewController, animated: true)
    }

    //MARK: -目录
    @objc private func outlineButtonDidClicked(sender: UIButton) {
        if let pdfoutline = self.pdfdocument?.outlineRoot {
            let oulineViewController = GTOulineTableviewController(style: UITableView.Style.plain)
            oulineViewController.navigationTitle = "书签"
            oulineViewController.pdfOutlineRoot = pdfoutline
            let nav = GTBaseNavigationViewController(rootViewController: oulineViewController)
            nav.modalPresentationStyle = .popover
            nav.preferredContentSize = CGSize(width: 300, height: 500)
            if let popoverController = nav.popoverPresentationController {
                popoverController.sourceView = sender
                popoverController.sourceRect = CGRect(x: sender.frame.size.width / 2.0, y: sender.frame.size.height, width: 0, height: 0)
                popoverController.permittedArrowDirections = .up
                popoverController.delegate = self
            }
            self.present(nav, animated: true)
        }
    }
    
    //MARK: -评论
    @objc private func commentButtonDidClicked() {
        navgationBarHiddenStatu = true
        let commentVC = GTCommentViewController(bookId: self.bookId)
        commentVC.pageNum = ((pdfdocument?.index(for: pdfView.currentPage!) ?? -1 ) + 1)
        self.addChild(commentVC)
        self.view.addSubview(commentVC.view)
        commentVC.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    // 视线跟踪图标
    @objc private func eyeButtonDidClicked() {
        if trackView.isHidden == false {
            self.eyeBtn.setImage(UIImage(named: "track_hide"), for: .normal)
            trackView.isHidden = true
        } else {
            self.eyeBtn.setImage(UIImage(named: "track_show"), for: .normal)
            trackView.isHidden = false
        }
    }
    
    // 翻页回调
    @objc private func handlePageChange(notification: Notification) {
        let pdfPage = pdfdocument?.index(for: pdfView.currentPage!) ?? 0
        
        // 每一次翻页都保存一次进度
        self.currentPage = pdfPage
        
        // 记录进入时间
        currentDate = Date.init().timeIntervalSince1970

        GTNet.shared.commitGazeTrackData(success: { (json) in
            self.sightDatas.removeAll()
        }, startTime: currentDate, lists: sightDatas, bookId: self.bookId, pageNum: pdfPage)
    }
    
    // 视线校准
    @objc private func adjustButtonDidClicked() {
        self.adjustBtn.isEnabled = false
        showTrackAlertController()
    }
}

extension GTReadViewController: GTThumbnailGridViewControllerDelegate {
    func thumbnailGridViewController(_ thumbnailGridViewController: GTThumbnailGridViewController, didSelectPage page: PDFPage) {
        pdfView.go(to: page)
        self.dismiss(animated: true, completion: nil)
    }
}

extension GTReadViewController: UIPopoverPresentationControllerDelegate {
    
}
