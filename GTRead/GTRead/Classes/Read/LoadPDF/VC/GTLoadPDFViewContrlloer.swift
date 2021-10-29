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

class GTLoadPDFViewContrlloer: GTBaseViewController {
    var pdfImageView: UIImageView!
    var progressView: UIProgressView!
    var progressLabel: UILabel!
    var bookNameLabel: UILabel!
    var button: UIButton!
    var dataModel: GTShelfBookItemModel
    var download: DownloadRequest!
    var isDownloading: Bool!
    var fileSize = 0.0
    
    init(model: GTShelfBookItemModel) {
        self.dataModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = dataModel.bookName
        
        pdfImageView = UIImageView()
        pdfImageView.layer.cornerRadius = 10
        pdfImageView.layer.masksToBounds = true
        pdfImageView.layer.shadowRadius = 5
        pdfImageView.layer.shadowOffset = CGSize(width: 0.0, height: -3.0)
        pdfImageView.layer.shadowOpacity = 0.1
        pdfImageView.sd_setImage(with: URL(string: self.dataModel.bookHeadUrl), placeholderImage: UIImage(named: "book_placeholder"))
        self.view.addSubview(pdfImageView)
        pdfImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(100)
            make.width.equalTo(200)
            make.height.equalTo(260)
        }

        bookNameLabel = UILabel()
        bookNameLabel.text = self.dataModel.bookName
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
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 10
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSize(width: 0.0, height: -3.0)
        button.layer.shadowOpacity = 0.1
        button.addTarget(self, action: #selector(buttonDidClicked), for: .touchUpInside)
        button.backgroundColor = UIColor(hexString: "#687ce3")
        self.view.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-100)
        }
        
        self.downloading()
        self.startDownloadPDF()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            self.download.cancel()
        }
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
        self.bookNameLabel.text = self.dataModel.bookName
        self.progressLabel.text = String(format: "%.2f", self.fileSize) + "M"
    }
     
    // 下载PDF
    func startDownloadPDF() {
        self.download = GTNet.shared.downloadBook(path: self.dataModel.bookId, url: self.dataModel.bookDownUrl, downloadProgress: {progress in
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
                let vc = GTReadViewController(path: URL(fileURLWithPath: GTDiskCache.sharedCachePDF.getFileURL(self.dataModel.bookId)))
                vc.hidesBottomBarWhenPushed = true;
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
    // 重新加载按钮
    @objc private func buttonDidClicked() {
        if self.isDownloading {
            self.canncel()
            self.download.cancel()
        } else {
            self.downloading()
            self.startDownloadPDF()
        }
    }
}
