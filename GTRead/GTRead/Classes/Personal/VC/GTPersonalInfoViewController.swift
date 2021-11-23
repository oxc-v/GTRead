//
//  GTPersonalInfoViewController.swift
//  GTRead
//
//  Created by Dev on 2021/10/18.
//

import UIKit
import PhotosUI
import SDWebImage


class GTPersonalInfoViewController: GTBaseViewController, UIPopoverPresentationControllerDelegate {

    var tableView: UITableView!
    var cellRowHeight = 70
    let cellInfo = [["头像"], ["昵称", "性别", "个性签名"]]
    var dataModel: GTPersonalInfoModel?
    
    var pickerView: UIPickerView!
    var pickerData = ["男", "女"]
    var pickerOkBtn: UIButton!
    var pickerCancelBtn: UIButton!
    var pickerToolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.navigationItem.title = "个人信息"
        
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(GTPersonalInfoViewCell.self, forCellReuseIdentifier: "GTPersonalInfoViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(80)
            make.left.right.bottom.equalToSuperview()
        }
        
        pickerView = UIPickerView(frame: CGRect.zero)
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerToolBar = UIToolbar()
        pickerToolBar.sizeToFit()
        pickerToolBar.tintColor = .white
        
        pickerOkBtn = UIButton(type: .custom)
        pickerOkBtn.setTitle("确定", for: .normal)
        pickerOkBtn.setTitleColor(UIColor(hexString: "#157efb"), for: .normal)
        pickerOkBtn.addTarget(self, action: #selector(pickerToolBarOkButtonDidClicked), for: .touchUpInside)
        self.pickerToolBar.addSubview(pickerOkBtn)
        pickerOkBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.top.equalTo(16)
        }

        pickerCancelBtn = UIButton(type: .custom)
        pickerCancelBtn.setTitle("取消", for: .normal)
        pickerCancelBtn.setTitleColor(UIColor(hexString: "#157efb"), for: .normal)
        pickerCancelBtn.addTarget(self, action: #selector(pickerToolBarCanncelButtonDidClicked), for: .touchUpInside)
        self.pickerToolBar.addSubview(pickerCancelBtn)
        pickerCancelBtn.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalTo(16)
        }
    }
    
    init(dataModel: GTPersonalInfoModel) {
        self.dataModel = dataModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 图片选择器
    func showPopoverPresentationController(cell: GTPersonalInfoViewCell) {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.preferredContentSize = CGSize(width: 150, height: 150)
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
        popoverPresentationController?.delegate = self
        popoverPresentationController?.backgroundColor = .white
        popoverPresentationController?.sourceRect = CGRect(x: cell.imgView.center.x , y: cell.frame.size.height, width: 0, height: 0)
        
        self.present(vc, animated: true, completion: nil)
    }
    
    // 调用相机
    func goCamera() {
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else{
            self.showWarningAlertController(message: "相机不可用")
         }
    }
    
    // 调用相册
    func goPhotoLibrary() {
        if #available(iOS 14, *) {
            var config = PHPickerConfiguration()
            config.selectionLimit = 1
            config.filter = PHPickerFilter.images
            
            let pickerViewController = PHPickerViewController(configuration: config)
            pickerViewController.delegate = self
            
            self.present(pickerViewController, animated: true, completion: nil)
        } else {
            self.showWarningAlertController(message: "您的系统版本过低，无法打开相册")
        }
    }
    
    @objc private func pickerToolBarOkButtonDidClicked() {
        self.view.endEditing(true)
        let pickerIndex = pickerView.selectedRow(inComponent: 0)
        self.uploadAccountInfo(imgData: nil, male: pickerIndex == 0 ? true : false)
    }
    
    @objc private func pickerToolBarCanncelButtonDidClicked() {
        self.view.endEditing(true)
    }
    
    // 上传信息
    func uploadAccountInfo(imgData: Data?, male: Bool?) {
        GTNet.shared.updateAccountInfo(headImgData: imgData, nickName: nil, profile: nil, male: male, age: nil, failure: {e in
            if GTNet.shared.networkAvailable() {
                self.hideActivityIndicatorView()
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
                    if imgData != nil {
                        // 删除头像图片缓存
                        SDImageCache.shared.removeImage(forKey: self.dataModel?.headImgUrl, withCompletion: nil)
                    }
                    // 账户信息修改通知
                    NotificationCenter.default.post(name: .GTAccountInfoChanged, object: self)
                    
                    self.showNotificationMessageView(message: male == nil ? "头像上传成功" : "修改成功")
                } else {
                    self.showNotificationMessageView(message: male == nil ? "头像上传失败" : "修改失败")
                }
            } else {
                self.showNotificationMessageView(message: "服务器数据错误")
            }
            self.hideActivityIndicatorView()
        })
    }
    
}

// UITableView
extension GTPersonalInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellInfo.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellInfo[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(self.cellRowHeight)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTPersonalInfoViewCell", for: indexPath) as! GTPersonalInfoViewCell
        
        cell.accessoryType = .disclosureIndicator
        cell.titleTxtLabel.text = cellInfo[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        cell.imgView.image = UIImage()
        cell.detailTextField.placeholder = ""

        if indexPath.section == 0 {
            cell.imgView.sd_setImage(with: URL(string: dataModel?.headImgUrl ?? ""), placeholderImage: UIImage(named: "profile"))
            cell.detailTextField.isUserInteractionEnabled = false
        } else if indexPath.section == 1 {
            let cellDetailTxt = [dataModel?.nickName, dataModel?.male == true ? "男" : "女", dataModel?.profile]
            cell.detailTextField.placeholder = cellDetailTxt[indexPath.row]
            
            if indexPath.row == 1 {
                // 替换键盘视图
                cell.detailTextField.inputView = pickerView
                cell.detailTextField.inputAccessoryView = pickerToolBar
                
                // 隐藏键盘工具栏
                cell.detailTextField.inputAssistantItem.leadingBarButtonGroups = []
                cell.detailTextField.inputAssistantItem.trailingBarButtonGroups = []
            } else {
                // 禁用编辑
                cell.detailTextField.isEnabled = false
                cell.detailTextField.isUserInteractionEnabled = false
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! GTPersonalInfoViewCell
        
        if indexPath.section == 0 {
            showPopoverPresentationController(cell: cell)
        } else if indexPath.section == 1 {
            if indexPath.row == 1 {
                cell.detailTextField.becomeFirstResponder()
            } else {
                self.hidesBottomBarWhenPushed = true
                // editType: 0表示编辑昵称、1表示编辑个性签名
                let vc = GTInfoEditViewController(title: cell.titleTxtLabel.text ?? "", text: cell.detailTextField.placeholder ?? "", editType: indexPath.row == 0 ? 0 : 1)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let sectionCount = tableView.numberOfRows(inSection: indexPath.section)
                let shapeLayer = CAShapeLayer()
        let cornerRadius = 10
        cell.layer.mask = nil
        if sectionCount > 1 {
            switch indexPath.row {
            case 0:
                var bounds = cell.bounds
                bounds.origin.y += 1.0
                let bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10,height: cornerRadius))
                shapeLayer.path = bezierPath.cgPath
                cell.layer.mask = shapeLayer
            case sectionCount - 1:
                var bounds = cell.bounds
                bounds.size.height -= 1.0
                let bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerRadius,height: cornerRadius))
                shapeLayer.path = bezierPath.cgPath
                cell.layer.mask = shapeLayer
            default:
                break
            }
        } else {
            let bezierPath = UIBezierPath(roundedRect: cell.bounds.insetBy(dx: 0.0,dy: 2.0), cornerRadius: CGFloat(cornerRadius))
            shapeLayer.path = bezierPath.cgPath
            cell.layer.mask = shapeLayer
        }
    }
}

// UIPickerView
extension GTPersonalInfoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerData[row]
    }
}


//UIImagePickerControllerDelegate
extension GTPersonalInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        self.showActivityIndicatorView()
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        if let imageData = image.pngData() {
            self.uploadAccountInfo(imgData: imageData, male: nil)
        } else {
            self.hideActivityIndicatorView()
            self.showNotificationMessageView(message: "暂不支持该文件格式")
        }

    }
}

// PHPickerViewController
extension GTPersonalInfoViewController: PHPickerViewControllerDelegate {
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        self.showActivityIndicatorView()
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                if let image = object as? UIImage {
                    if let imageData = image.pngData() {
                        self.uploadAccountInfo(imgData: imageData, male: nil)
                    } else {
                        self.hideActivityIndicatorView()
                        self.showNotificationMessageView(message: "暂不支持该文件格式")
                    }
                }
            })
        }
    }
}
