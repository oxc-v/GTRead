//
//  GTAccountDetailInfoTableViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/29.
//

import Foundation
import UIKit
import PhotosUI
import SDWebImage
import Presentr

class GTAccountDetailInfoTableViewController: GTTableViewController {
    
    var loadingView: GTLoadingView!
    
    private var accountInfoDataModel: GTAccountInfoDataModel? = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
    private let cellHeight = 50.0
    private let cellInfo = [["账号"], ["头像"], ["昵称", "性别", "个性签名"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NavigationBar
        self.setupNavigationBar()
        // TableView
        self.setupTableView()
        
        // 注册账户信息修改的通知
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableviewData), name: .GTAccountInfoChanged, object: nil)
    }
    
    // NavigationBar
    private func setupNavigationBar() {
        self.navigationItem.title = "账户信息"
        
        loadingView = GTLoadingView(colors: [UIColor(hexString: "#12c2e9"), UIColor(hexString: "#c471ed"), UIColor(hexString: "#f64f59")], lineWidth: 3)
        loadingView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        loadingView.isAnimating = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingView)
    }
    
    // TableView
    private func setupTableView() {
        tableView.register(GTAccountDetailInfoImgTableViewCell.self, forCellReuseIdentifier: "GTAccountDetailInfoImgTableViewCell")
        tableView.register(GTAccountManagerCommonTableViewCell.self, forCellReuseIdentifier: "GTAccountManagerCommonTableViewCell")
    }
    
    // 更新TableView数据
    @objc private func reloadTableviewData() {
        self.accountInfoDataModel = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        self.tableView.reloadData()
    }
    
    // 图片选择器
    private func showImgPopoverController(cell: GTAccountDetailInfoImgTableViewCell) {
        
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.preferredContentSize = CGSize(width: 50, height: 50)
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let photoAction = UIAlertAction(title: "从相册选择", style: .default) { action in
            self.goPhotoLibrary()
        }
        let cameraAction = UIAlertAction(title: "拍照", style: .default) { action in
            self.goCamera()
        }
        vc.addAction(photoAction)
        vc.addAction(cameraAction)
        
        let popoverPresentationController = vc.popoverPresentationController
        popoverPresentationController?.sourceView = cell
        popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popoverPresentationController?.backgroundColor = .white
        popoverPresentationController?.sourceRect = CGRect(x: cell.imgView.center.x , y: cell.frame.size.height, width: 0, height: 0)
        
        self.present(vc, animated: true, completion: nil)
    }
    
    // 调用相机
    private func goCamera() {
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else{
            self.showNotificationMessageView(message: "相机不可用")
         }
    }
    
    // 调用相册
    private func goPhotoLibrary() {
        if #available(iOS 14, *) {
            var config = PHPickerConfiguration()
            config.selectionLimit = 1
            config.filter = PHPickerFilter.images
            
            let pickerViewController = PHPickerViewController(configuration: config)
            pickerViewController.delegate = self
            
            self.present(pickerViewController, animated: true, completion: nil)
        } else {
            self.showNotificationMessageView(message: "您的系统版本过低，无法打开相册")
        }
    }
    
    // 上传信息
    private func uploadAccountInfo(imgData: Data?) {
        DispatchQueue.main.async {
            self.loadingView.isAnimating = true
        }
        GTNet.shared.updateAccountInfo(headImgData: imgData, nickName: nil, profile: nil, male: nil, age: nil, failure: {e in
            self.loadingView.isAnimating = false
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
        }, success: {json in
            // 提取数据
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            if let dataModel = try? decoder.decode(GTErrorDataModel.self, from: data!) {
                if dataModel.code == 1 {
                    // 删除头像图片缓存
                    SDImageCache.shared.removeImage(forKey: self.accountInfoDataModel?.headImgUrl, withCompletion: {
                        SDImageCache.shared.store(nil, imageData: imgData, forKey: self.accountInfoDataModel?.headImgUrl, toDisk: true, completion: {
                            // 账户信息修改通知
                            NotificationCenter.default.post(name: .GTAccountInfoChanged, object: self)
                            self.showNotificationMessageView(message: "头像上传成功")
                            self.loadingView.isAnimating = false
                        })
                    })
                } else {
                    self.loadingView.isAnimating = false
                    self.showNotificationMessageView(message: "头像上传失败")
                }
            } else {
                self.loadingView.isAnimating = false
                self.showNotificationMessageView(message: "服务器数据错误")
            }
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return cellInfo.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellInfo[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountManagerCommonTableViewCell", for: indexPath) as! GTAccountManagerCommonTableViewCell
            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.titleLabel.text = self.cellInfo[indexPath.section][indexPath.row]
            cell.detailLabel.text = self.accountInfoDataModel?.userId
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountDetailInfoImgTableViewCell", for: indexPath) as! GTAccountDetailInfoImgTableViewCell
            cell.selectionStyle = .none
            cell.accessoryType = .disclosureIndicator
            cell.titleLabel.text = self.cellInfo[indexPath.section][indexPath.row]
            cell.imgView.sd_setImage(with: URL(string: self.accountInfoDataModel?.headImgUrl ?? ""), placeholderImage: UIImage(named: "head_placeholder"))
            return cell
        default:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountManagerCommonTableViewCell", for: indexPath) as! GTAccountManagerCommonTableViewCell
                cell.selectionStyle = .none
                cell.accessoryType = .disclosureIndicator
                cell.titleLabel.text = self.cellInfo[indexPath.section][indexPath.row]
                cell.detailLabel.text = self.accountInfoDataModel?.nickName
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountManagerCommonTableViewCell", for: indexPath) as! GTAccountManagerCommonTableViewCell
                cell.selectionStyle = .none
                cell.accessoryType = .disclosureIndicator
                cell.titleLabel.text = self.cellInfo[indexPath.section][indexPath.row]
                cell.detailLabel.text = self.accountInfoDataModel!.male ? "男" : "女"
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountManagerCommonTableViewCell", for: indexPath) as! GTAccountManagerCommonTableViewCell
                cell.selectionStyle = .none
                cell.accessoryType = .disclosureIndicator
                cell.titleLabel.text = self.cellInfo[indexPath.section][indexPath.row]
                cell.detailLabel.text = self.accountInfoDataModel?.profile
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            let cell = tableView.cellForRow(at: indexPath) as! GTAccountDetailInfoImgTableViewCell
            showImgPopoverController(cell: cell)
        case 2:
            let cell = tableView.cellForRow(at: indexPath) as! GTAccountManagerCommonTableViewCell
            switch indexPath.row {
            case 0:
                let vc = GTBaseNavigationViewController(rootViewController: GTAccountTextEditViewController(editType: 0))
                self.customPresentViewController(self.getPresenter(widthFluid: 0.64, heightFluid: 0.53), viewController: vc, animated: true, completion: nil)
            case 1:
                let vc = GTBaseNavigationViewController(rootViewController: GTSexPickerViewController(viewController: self))
                vc.modalPresentationStyle = .popover
                vc.preferredContentSize = CGSize(width: 160, height: 80)
                if let popoverController = vc.popoverPresentationController {
                    popoverController.sourceView = cell.detailLabel
                    popoverController.sourceRect = CGRect(x: cell.detailLabel.frame.size.width / 2.0, y: cell.detailLabel.frame.size.height, width: 0, height: 0)
                    popoverController.permittedArrowDirections = .up
                }
                self.present(vc, animated: true)
            default:
                let vc = GTBaseNavigationViewController(rootViewController: GTAccountTextEditViewController(editType: 1))
                self.customPresentViewController(self.getPresenter(widthFluid: 0.64, heightFluid: 0.53), viewController: vc, animated: true, completion: nil)
            }
        default:
            break
        }
    }
}

//UIImagePickerControllerDelegate
extension GTAccountDetailInfoTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        if let imageData = image.pngData() {
            self.uploadAccountInfo(imgData: imageData)
        } else {
            self.showNotificationMessageView(message: "暂不支持该文件格式")
        }
    }
}

// PHPickerViewController
extension GTAccountDetailInfoTableViewController: PHPickerViewControllerDelegate {
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                if let image = object as? UIImage {
                    if let imageData = image.pngData() {
                        self.uploadAccountInfo(imgData: imageData)
                    } else {
                        self.showNotificationMessageView(message: "暂不支持该文件格式")
                    }
                }
            })
        }
    }
}
