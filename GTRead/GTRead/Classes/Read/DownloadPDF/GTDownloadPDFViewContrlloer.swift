//
//  LoadPDFViewContrlloer.swift
//  GTRead
//
//  Created by Dev on 2021/10/28.
//

import UIKit
import PDFKit
import SDWebImage
import Alamofire

class GTDownloadPDFViewContrlloer: GTBaseViewController {
    
    private var finishedBtn: UIButton!
    private var gtImageView: GTShadowImageView!
    private var pdfImageView: UIImageView!
    private var progressView: UIProgressView!
    private var progressLabel: UILabel!
    private var bookNameLabel: UILabel!
    private var button: UIButton!
    
    private var dataModel: GTBookDataModel
    private var download: DownloadRequest!
    private var isDownloading: Bool!
    private var fileSize = 0.0
    
    init(model: GTBookDataModel) {
        self.dataModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.setupNavigationBar()
        
        gtImageView = GTShadowImageView(opacity: 0.15)
        gtImageView.imgView.layer.cornerRadius = 5
        gtImageView.imgView.clipsToBounds = true
        gtImageView.imgView.sd_setImage(with: URL(string: self.dataModel.downInfo.bookHeadUrl), placeholderImage: UIImage(named: "book_placeholder"))
        self.pdfImageView = gtImageView.imgView
        self.view.addSubview(gtImageView)
        gtImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(100)
            make.width.equalTo(200)
            make.height.equalTo(270)
        }

        bookNameLabel = UILabel()
        bookNameLabel.text = self.dataModel.baseInfo.bookName
        bookNameLabel.textAlignment = .center
        bookNameLabel.lineBreakMode = .byTruncatingMiddle
        bookNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.view.addSubview(bookNameLabel)
        bookNameLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(pdfImageView.snp.width)
            make.top.equalTo(pdfImageView.snp.bottom).offset(60)
        }
        
        progressLabel = UILabel()
        progressLabel.textAlignment = .center
        progressLabel.font = UIFont.systemFont(ofSize: 16)
        progressLabel.textColor = UIColor(hexString: "#b4b4b4")
        self.view.addSubview(progressLabel)
        progressLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(pdfImageView.snp.width)
            make.top.equalTo(bookNameLabel.snp.bottom).offset(50)
        }
        
        progressView = UIProgressView()
        progressView.setProgress(0, animated: false)
        progressView.isHidden = true
        self.view.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.top.equalTo(progressLabel.snp.bottom).offset(50)
        }
        
        button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.layer.cornerRadius = 25
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSize(width: 0.0, height: -3.0)
        button.layer.shadowOpacity = 0.1
        button.addTarget(self, action: #selector(buttonDidClicked(sender:)), for: .touchUpInside)
        button.backgroundColor = .black
        self.view.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(170)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-100)
        }
        
        self.downloading()
        self.startDownloadPDF()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.download.cancel()
    }
    
    // NavigationBar
    private func setupNavigationBar() {
        finishedBtn = UIButton(type: .custom)
        finishedBtn.setTitle("完成", for: .normal)
        finishedBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        finishedBtn.setTitleColor(.systemBlue, for: .normal)
        finishedBtn.addTarget(self, action: #selector(finishedBtnDidClicked(sender:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: finishedBtn)
        self.navigationItem.title = dataModel.baseInfo.bookName
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    // finishedBtn clicked
    @objc private func finishedBtnDidClicked(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.1, completion: { _ in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    // Downloading
    private func downloading() {
        self.isDownloading = true
        button.setTitle("取消加载", for: .normal)
        self.progressView.isHidden = false
        self.bookNameLabel.text = "正在加载"
    }
    
    // Canncel
    private func canncel() {
        self.isDownloading = false
        button.setTitle("重新加载", for: .normal)
        self.progressView.isHidden = true
        self.progressView.setProgress(0, animated: false)
        self.bookNameLabel.text = self.dataModel.baseInfo.bookName
        self.progressLabel.text = String(format: "%.2f", self.fileSize) + "M"
    }
     
    // 下载PDF
    func startDownloadPDF() {
        self.download = GTNet.shared.downloadBook(path: self.dataModel.bookId, url: self.dataModel.downInfo.bookDownUrl, downloadProgress: {progress in
            DispatchQueue.main.async {
                self.progressView.setProgress(Float(progress.fractionCompleted), animated: true)
                self.fileSize = Double(progress.totalUnitCount) / 1024 / 1024
                self.progressLabel.text = String(format: "%.2f", self.fileSize * progress.fractionCompleted) + "/" + String(format: "%.2f",  self.fileSize) + "M"
            }
        }, failure: {error in
            DispatchQueue.main.async {
                self.showNotificationMessageView(message: "文件下载失败")
                self.canncel()
            }
        }, success: {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: {
                    let userInfo = ["dataModel": self.dataModel]
                    NotificationCenter.default.post(name: .GTDownloadBookFinished, object: self, userInfo: userInfo)
                })
            }
        })
    }
    
    // 重新加载按钮
    @objc private func buttonDidClicked(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.2, completion: {_ in
            if self.isDownloading {
                self.canncel()
                self.download.cancel()
            } else {
                self.downloading()
                self.startDownloadPDF()
            }
        })
    }
}
