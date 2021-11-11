//
//  GTNet.swift
//  GTRead
//
//  Created by YangJie on 2021/3/2.
//

import Alamofire
import CryptoKit


typealias Success = (_ response: AnyObject) -> Void
typealias Failure = (_ error: AnyObject) -> Void

// 请求方法
enum RequestType: Int {
    case get
    case post
    case download
}

// 网络状态
enum NetworkStatus {
    case unknown    //未知网络
    case notReachable   //未联网
    case wwan   //蜂窝数据
    case wifi
}

final class GTNet {
    private init() {
        // 监听网络状态
        self.monitorNetworkingStatus()
    }
    static let shared = GTNet()
    
    private var sessionManager: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        let session = Session.init(configuration: configuration, delegate: SessionDelegate.init(), serverTrustManager: nil)
        return session
    }()
    
    // 请求基本路径
    let base_url = "http//gtread.com/"
    
    // 网络状态
    var networkStatus: NetworkStatus?
    
    // 数据缓存路径
    private let cachePath = NSHomeDirectory() + "/Documents/NetworkingCaches/"
    
}
/// 网络状态监听
extension GTNet {
    
    func monitorNetworkingStatus() {
        let reachability = NetworkReachabilityManager()
        reachability?.startListening(onUpdatePerforming: {[weak self] (status) in
            guard let weakSelf = self else { return }
            if reachability?.isReachable ?? false {
                switch status {
                case .notReachable:
                    self?.networkStatus = .notReachable
                    weakSelf.networkStatus = .notReachable
                case .unknown:
                    self?.networkStatus = .unknown
                    weakSelf.networkStatus = .unknown
                case .reachable(.cellular):
                    self?.networkStatus = .wwan
                    weakSelf.networkStatus = .wwan
                case .reachable(.ethernetOrWiFi):
                    self?.networkStatus = .wifi
                    weakSelf.networkStatus = .wifi
                }
            } else {
                self?.networkStatus = .notReachable
                weakSelf.networkStatus = .notReachable
            }
        })
    }
    
    // 判断当前网络是否可用
    func networkAvailable() -> Bool {
        guard let status = self.networkStatus else { return false }
        
        if status == .unknown || status == .notReachable {
            return false
        }
        
        return true
    }
    
    
    // 判断是否为wifi环境
    func isWIFI() -> Bool {
        guard let status = self.networkStatus else { return false }
        
        if !self.networkAvailable() || status == .wwan { return false }

        return true
    }
          
}

/// 数据缓存
extension GTNet {
    //新建数据缓存路径
    func createRootCachePath(path: String) {
        if !FileManager.default.fileExists(atPath: path, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                debugPrint("create cache dir error:" + error.localizedDescription + "\n")
                return
            }
        }
    }
    
    // 读取缓存
    public func cacheDataFrom(urlPath: String) -> Any? {
        //对请求路由base64编码
        let base64Path = urlPath.MD5
        //拼接缓存路径
        var directorPath: String = cachePath
        directorPath.append(base64Path)
        let data: Data? = FileManager.default.contents(atPath: cachePath + base64Path)
        let jsonData: Any?
        if data != nil {
            print("从缓存中获取数据:\(directorPath)")
            do {
                jsonData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                return jsonData
            } catch {
                return data
            }
        }
        return nil
    }
    
    // 进行数据缓存
    public func cacheResponseDataWith(responseData: AnyObject,
                                          urlPath: String) {
        var directorPath: String = cachePath
        //创建目录
        createRootCachePath(path: directorPath)
        //对请求的路由进行base64编码
        let base64Path = urlPath.MD5
        //拼接路径
        directorPath.append(base64Path)
        //将返回的数据转换成Data
        var data: Data?
        do {
            try data = JSONSerialization.data(withJSONObject: responseData, options: .prettyPrinted)
        } catch {
            debugPrint("GTNet->cacheResponseDataWith")
        }
        //将data存储到指定的路径
        if data != nil {
            let cacheSuccess = FileManager.default.createFile(atPath: directorPath, contents: data, attributes: nil)
            if cacheSuccess == true {
                debugPrint("当前接口缓存成功:\(directorPath)")
            } else {
                debugPrint("当前接口缓存失败:\(directorPath)")
            }
        }
    }
}




/// 数据请求
extension GTNet {
    func requestWith(url: String, httpMethod: RequestType, params: [String: Any]?, headers: HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"], success: @escaping Success, error: @escaping Failure) {
        switch httpMethod {
        case .get:
            manageGet(url: url, params: params, headers: headers, success: success, error: error)
        case .post:
            managePost(url: url, params: params, headers: headers, success: success, error: error)
        default:
            break
        }
    }
    private func manageGet(url: String, params: [String: Any]?, headers: HTTPHeaders, success: @escaping Success, error: @escaping Failure) {
        let urlPath:URL = URL(string: url)!
        let request = AF.request(urlPath,method: .get,parameters: params,encoding: JSONEncoding.default, headers: headers)
        request.responseJSON { (response) in
            DispatchQueue.global().async(execute: {
                DispatchQueue.global().async(execute: {
                    switch response.result {
                    case .success(let value):
                        success(value as AnyObject)
                    case .failure:
                        let statusCode = response.response?.statusCode
                        error(statusCode as AnyObject)
                    }
                })
            })
        }
    }
    // 字典参数 ["id":"1","value":""]
    private func managePost(url: String,
                            params: [String: Any]?,
                            headers: HTTPHeaders,
                            success: @escaping Success,
                            error: @escaping Failure) {
        let urlPath:URL = URL(string: url)!
        let request = AF.request(urlPath,method: .post,parameters: params,encoding: JSONEncoding.default, headers: headers)
        request.responseJSON { (response) in
            DispatchQueue.main.async(execute: {
                switch response.result {
                case .success(let value):
                    success(value as AnyObject)
                case .failure:
                    let statusCode = response.response?.statusCode
                    error(statusCode as AnyObject)
                }
            })
        }
    }
}

// 书架
extension GTNet {
    // 获取书架书籍
    func getShelfBook(failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let params = ["userId": UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? ""] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8003/bookShelfService/getMyshelfFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (e) in
           failure(e)
        }
    }
    
    // 删除书架书籍
    func delShelfBook(books: Array<GTShelfBookItemModel>, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        var bookIds = [String]()
        print(books.count)
        for item in books {
            print(item.bookId)
            bookIds.append(item.bookId)
        }
        let params = ["userId": UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "", "bookIds": bookIds] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8003/bookShelfService/delFromShelfFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (e) in
           failure(e)
        }
    }
    
    // 下载书籍
    func downloadBook(path: String, url: String, downloadProgress: @escaping ((Progress)->()?), failure: @escaping ((String)->()), success: @escaping (()->())) -> DownloadRequest {
        let progressQueue = DispatchQueue(label: "com.alamofire.progressQueue", qos: .utility)
        let destination: DownloadRequest.Destination = { _, _ in
            let userFolder = UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? ""
            let pdfFolder = "PDFDocument"
            let path_1 = (GTDiskCache.shared.diskCachePath as NSString).appendingPathComponent(userFolder)
            let path_2 = (path_1 as NSString).appendingPathComponent(pdfFolder)
            let path_3 = (path_2 as NSString).appendingPathComponent(path + ".pdf")

            return (URL(fileURLWithPath: path_3), [.removePreviousFile, .createIntermediateDirectories])
        }
        let download = AF.download(url, to: destination)
            .downloadProgress(queue: progressQueue) { progress in
                downloadProgress(progress)
            }
            .response { response in
                switch response.result {
                case .success(_):
                    success()
                    print("文件下载完毕: \(response)")
                case .failure(let error):
                    failure("文件下载失败")
                    print(error)
                }
            }
        
        return download
    }
}

// 个人信息管理
extension GTNet {
    
    // 获取个人信息
    func getPersonalInfo(failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let params = ["userId" : UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? ""] as [String : Any]
        GTNet.shared.requestWith(url: "http://39.105.217.90:8007/accountService/userInfoFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
    
    // 注册请求
    func requestRegister(userId: String, userPwd: String, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let params = ["userId": userId, "userPwd": userPwd] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8007/accountService/registerFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (e) in
            failure(e)
        }
    }
    
    // 登录请求
    func requestLogin(userId: String, userPwd: String, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let params = ["userId": userId, "userPwd": userPwd] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8007/accountService/loginFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (e) in
            failure(e)
        }
    }
    
    // 更改密码
    func updatePassword(pwd: String, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let params = ["userId": UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "", "newPassword": pwd] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8007/accountService/updatePasswdFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (e) in
            failure(e)
        }
    }
    
    // 修改用户信息
    func updateAccountInfo(headImgData: Data?, nickName: String?, profile: String?, male: Bool?, age: Int?, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        var params = ["userId": UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "", "userPwd": (UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.password) ?? "")] as [String : Any]
        if nickName != nil {
            params.updateValue(nickName as Any, forKey: "nickName")
        }
        if profile != nil {
            params.updateValue(profile as Any, forKey: "profile")
        }
        if male != nil {
            params.updateValue(male as Any, forKey: "male")
        }
        if age != nil {
            params.updateValue(age as Any, forKey: "age")
        }
        if headImgData != nil {
            let imageBase64String = headImgData?.base64EncodedString()
            params.updateValue(imageBase64String as Any, forKey: "headImgData")
        }
        
        self.requestWith(url: "http://39.105.217.90:8007/accountService/setUserInfoFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (e) in
            failure(e)
        }
    }
}

extension GTNet {
    // 上传评论
    func addCommentList(success: @escaping ((AnyObject)->()), bookId: String, pageNum: Int, parentId: Int = 0, timeStamp: String, commentContent: String) {
        let params = ["bookId": bookId, "pageNum": pageNum, "commentContent": commentContent, "userId": UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "", "timestamp": timeStamp, "parentId": parentId] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8005/commonService/addCommentFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (e) in
            debugPrint(e)
        }
    }

    // 获得评论
    func getCommentList(success: @escaping ((AnyObject)->()),error: @escaping ((AnyObject)->()), bookId: String, pageNum: Int) {
        let params = ["userId" : UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "", "bookId": bookId, "pageNum": pageNum] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8005/commonService/getCommentFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (e) in
            error(e)
        }
    }
    
    // 发送视线数据
    func commitGazeTrackData(success: @escaping ((AnyObject)->()), startTime: TimeInterval, lists: Array<[String:Any]>, bookId: String, pageNum: Int) {
        let date = Date.init()
        let endTime = date.timeIntervalSince1970
        let params = ["userId" : UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "",  "bookId": bookId, "pageNum": pageNum, "startTime": String(startTime), "endTime": String(endTime), "lists" : lists] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8004/collectService/collectReadDataFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            debugPrint(error)
        }
    }
}

extension GTNet {
    
    // 获取每日阅读目标
    func getReadTarget(failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let params = ["userId" : UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? ""] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8004/collectService/getTargetMinuteFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
    
    // 上传每日目标
    func setReadTarget(minute: Int, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let params = ["userId" : UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "", "minute": minute] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8004/collectService/setTargetMinuteFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
    
    // 获取分析数据
    func getAnalyseData(failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dayTime = dateFormatter.string(from: Date())
        let params = ["userId" : UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "",  "dayTime": dayTime] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8004/collectService/getReadTimeCount", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
}

extension String {
    var MD5: String {
        let computed = Insecure.MD5.hash(data: self.data(using: .utf8)!)
        return computed.map { String(format: "%02hhx", $0) }.joined()
    }
}
