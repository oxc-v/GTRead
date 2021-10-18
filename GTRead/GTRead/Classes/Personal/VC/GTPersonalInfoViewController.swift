//
//  GTPersonalInfoViewController.swift
//  GTRead
//
//  Created by Dev on 2021/10/18.
//

import UIKit

class GTPersonalInfoViewController: GTBaseViewController, UITableViewDelegate, UITableViewDataSource {

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
        
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(GTPersonalInfoViewCell.self, forCellReuseIdentifier: "GTPersonalInfoViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalToSuperview()
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
        pickerOkBtn.addTarget(self, action: #selector(pickerToolBarButtonDidClicked), for: .touchUpInside)
        self.pickerToolBar.addSubview(pickerOkBtn)
        pickerOkBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.top.equalTo(16)
        }

        pickerCancelBtn = UIButton(type: .custom)
        pickerCancelBtn.setTitle("取消", for: .normal)
        pickerCancelBtn.setTitleColor(UIColor(hexString: "#157efb"), for: .normal)
        pickerCancelBtn.addTarget(self, action: #selector(pickerToolBarButtonDidClicked), for: .touchUpInside)
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

        if indexPath.section == 0 {
            cell.imgView.sd_setImage(with: URL(string: dataModel?.headImgUrl ?? ""), placeholderImage: UIImage(named: "profile"))
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
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
        } else if indexPath.section == 1 {
            self.view.endEditing(true)
            let cell = tableView.cellForRow(at: indexPath) as! GTPersonalInfoViewCell
            cell.detailTextField.becomeFirstResponder()
        }
    }
    
    // 选择器按钮
    @objc private func pickerToolBarButtonDidClicked() {
        self.view.endEditing(true)
    }
}

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
