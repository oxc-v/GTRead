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
                    print(response)
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
        let dataModel: GTAccountInfoDataModel? = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        let params = ["userId": dataModel!.userId] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8003/bookShelfService/getMyshelfFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (e) in
           failure(e)
        }
    }
    
    // 删除书架书籍
    func delShelfBook(books: Array<GTBookDataModel>, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let dataModel: GTAccountInfoDataModel? = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        var bookIds = [String]()
        for item in books {
            bookIds.append(item.bookId)
        }
        let params = ["userId": dataModel!.userId, "bookIds": bookIds] as [String : Any]
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
            let pdfFolder = "PDFDocument"
            let path_1 = (GTDiskCache.shared.diskCachePath as NSString).appendingPathComponent(pdfFolder)
            let path_2 = (path_1 as NSString).appendingPathComponent(path + ".pdf")

            return (URL(fileURLWithPath: path_2), [.removePreviousFile, .createIntermediateDirectories])
        }
        let download = AF.download(url, to: destination)
            .downloadProgress(queue: progressQueue) { progress in
                downloadProgress(progress)
            }
            .response { response in
                if let code = response.response?.statusCode {
                    switch code {
                    case 404:
                        // 删除缓存
                        GTDiskCache.shared.deletePDF(path)
                        failure("文件下载失败")
                    default:
                        switch response.result {
                        case .success(_):
                            success()
                            print("文件下载完毕: \(response)")
                        case .failure(let error):
                            failure("文件下载失败")
                            print(error)
                        }
                    }
                }
            }
        
        return download
    }
    
    // 添加书籍到书库
    func addBookToShelfFun(bookId: String, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        // 只有登录账户之后才能添加书籍到书库
        let dataModel: GTAccountInfoDataModel? = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        let date = Date.init()
        let timeStamp = date.timeIntervalSince1970
        let params = ["userId" : dataModel!.userId, "bookId": bookId, "addTime": String(timeStamp)] as [String : Any]
        GTNet.shared.requestWith(url: "http://39.105.217.90:8003/bookShelfService/addToShelfFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
}

// 个人信息管理
extension GTNet {
    
    // 获取个人信息
    func getAccountInfo(userId: Int, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let params = ["userId" : userId] as [String : Any]
        GTNet.shared.requestWith(url: "http://39.105.217.90:8007/accountService/userInfoFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
    
    // 注册请求
    func requestRegister(userPwd: String, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let params = ["userPwd": userPwd] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8007/accountService/registerFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (e) in
            failure(e)
        }
    }
    
    // 登录请求
    func requestLogin(userId: Int, userPwd: String, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let params = ["userId": userId, "userPwd": userPwd] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8007/accountService/loginFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (e) in
            failure(e)
        }
    }
    
    // 更改密码
    func updatePassword(pwd: String, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let dataModel: GTAccountInfoDataModel? = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        let params = ["userId": dataModel!.userId, "newPassword": pwd] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8007/accountService/updatePasswdFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (e) in
            failure(e)
        }
    }
    
    // 修改用户信息
    func updateAccountInfo(headImgData: Data?, nickName: String?, profile: String?, male: Int?, age: Int?, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let dataModel: GTAccountInfoDataModel? = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        var params = ["userId": dataModel!.userId, "userPwd": (UserDefaults.standard.string(forKey: GTUserDefaultKeys.GTAccountPassword) ?? "")] as [String : Any]
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
        let dataModel: GTAccountInfoDataModel? = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        let params = ["bookId": bookId, "pageNum": pageNum, "commentContent": commentContent, "userId": dataModel!.userId, "timestamp": timeStamp, "parentId": parentId] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8005/commonService/addCommentFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (e) in
            debugPrint(e)
        }
    }

    // 获得评论
    func getCommentList(success: @escaping ((AnyObject)->()),error: @escaping ((AnyObject)->()), bookId: String, pageNum: Int) {
        let dataModel: GTAccountInfoDataModel? = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        let params = ["userId" : dataModel!.userId, "bookId": bookId, "pageNum": pageNum] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8005/commonService/getCommentFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (e) in
            error(e)
        }
    }
    
    // 发送视线数据
    func commitGazeTrackData(success: @escaping ((AnyObject)->()), startTime: TimeInterval, lists: Array<[String:Any]>, bookId: String, pageNum: Int) {
        let dataModel: GTAccountInfoDataModel? = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        let date = Date.init()
        let endTime = date.timeIntervalSince1970
        let params = ["userId" : dataModel!.userId,  "bookId": bookId, "pageNum": pageNum, "startTime": String(startTime), "endTime": String(endTime), "lists" : lists] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8004/collectService/collectReadDataFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            debugPrint(error)
        }
    }
}

// 书店
extension GTNet {
    // 书店轮播书籍
    func getBookStoreADBooks(failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        self.requestWith(url: "http://39.105.217.90:8002/bookCityService/getBookADSFun", httpMethod: .post, params: nil) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
}

// 书籍
extension GTNet {
    
    // 添加书籍评论
    func addBookComment(userId: Int, bookId: String, score: Int, title: String, content: String, remarkTime: String, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {

        let params = ["userId" : userId, "score": score, "bookId": bookId, "title": title, "content" : content, "remarkTime": remarkTime] as [String : Any]
        
        self.requestWith(url: "http://39.105.217.90:8005/BookCommentService/addCommentFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
    
    // 获取书籍的评论列表
    func getBookCommentLists(observer: Int, offset: Int, count: Int, bookId: String, pattern: GTBookCommentPattern, reverse: Bool, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        
        let params = ["observer" : observer,  "offset": offset, "count": count, "bookId": bookId, "pattern": pattern.rawValue, "reverse" : reverse] as [String : Any]
        
        self.requestWith(url: "http://39.105.217.90:8005/BookCommentService/getBookCommentFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
    
    // 点赞书籍评论
    func hitBookComment(userId: Int, praised: Int, bookId: String, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        
        let params = ["hitter": userId,  "praised": praised, "bookId": bookId] as [String : Any]
        
        self.requestWith(url: "http://39.105.217.90:8005/BookCommentService/hitCommentFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
    
    // 取消点赞
    func cancelHitBookComment(userId: Int, praised: Int, bookId: String, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        
        let params = ["hitter": userId,  "praised": praised, "bookId": bookId] as [String : Any]
        
        self.requestWith(url: "http://39.105.217.90:8005/BookCommentService/CancalHitCommentFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
    
    // 获取顶层页评论
    func getTopPDFCommentFun(observer: Int, offset: Int, count: Int, bookId: String, pattern: GTPDFCommentPattern, reverse: Bool, page: Int,  failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let params = ["observer" : observer,  "offset": offset, "count": count, "bookId": bookId, "pattern": pattern.rawValue, "reverse" : reverse, "page": page] as [String : Any]
        
        self.requestWith(url: "http://39.105.217.90:8008/PageCommentService/getTopCommentFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
    
    // 获取子页评论
    func getSubPDFCommentFun(observer: Int, offset: Int, count: Int, bookId: String, pattern: GTPDFCommentPattern, reverse: Bool, page: Int, parentId: Int, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let params = ["observer" : observer,  "offset": offset, "count": count, "bookId": bookId, "pattern": pattern.rawValue, "reverse" : reverse, "page": page, "parentId": parentId] as [String : Any]
        
        self.requestWith(url: "http://39.105.217.90:8008/PageCommentService/getSubCommentFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
    
    // 添加顶层页评论
    func addTopCommentFun(userId: Int, bookId: String, page: Int, title: String, content: String, remarkTime: String, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        
        let params = ["userId" : userId, "page": page, "bookId": bookId, "title": title, "content" : content, "remarkTime": remarkTime] as [String : Any]
        
        self.requestWith(url: "http://39.105.217.90:8008/PageCommentService/addTopCommentFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
    
    // 添加子页评论
    func addSubCommentFun(userId: Int, bookId: String, page: Int, title: String, content: String, remarkTime: String, parentId: Int, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        
        let params = ["userId" : userId, "page": page, "bookId": bookId, "title": title, "content" : content, "remarkTime": remarkTime, "parentId": parentId] as [String : Any]
        
        self.requestWith(url: "http://39.105.217.90:8008/PageCommentService/addSubCommentFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
    
    // 点赞页码评论
    func hitPDFCommentFun(userId: Int, praised: Int, bookId: String, page: Int, commentId: Int, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        
        let params = ["hitter": userId, "praised": praised, "bookId": bookId, "page": page, "commentId": commentId] as [String : Any]
        
        self.requestWith(url: "http://39.105.217.90:8008/PageCommentService/hitCommentFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
    
    
    // 取消点赞页码评论
    func cancelHitPDFCommentFun(userId: Int, praised: Int, bookId: String, page: Int, commentId: Int, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        
        let params = ["hitter": userId, "praised": praised, "bookId": bookId, "page": page, "commentId": commentId] as [String : Any]
        
        self.requestWith(url: "http://39.105.217.90:8008/PageCommentService/CancalHitCommentFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
}

// 书城
extension GTNet {
    // 获取推送书籍
    func getPushBookLists(offset: Int, size: Int, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let params = ["offset": offset, "size": size] as [String : Any]
        
        self.requestWith(url: "http://39.105.217.90:8002/bookCityService/getPushBooksFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
    
    // 获取某个类型的书籍
    func getBookListsForType(type: GTBookType, offset: Int, count: Int, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let params = ["bookType": type.rawValue, "offset": offset, "count": count] as [String : Any]
        
        self.requestWith(url: "http://39.105.217.90:8002/bookCityService/getTypedBooksFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
}

// 搜索
extension GTNet {
    // 搜索书籍
    func searchBookInfoFun(searchStr: String, searchType: GTSearchType, dayTime: String, count: Int, offset: Int, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        
        let params = [searchType.rawValue: searchStr, "dayTime": dayTime, "count": count, "offset": offset, "userId": 10000] as [String : Any]
        
        self.requestWith(url: "http://39.105.217.90:8002/bookCityService/searchBookInfoFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
    
    // 获取热搜书籍
    func getPopularSearchFun(count: Int, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dayTime = dateFormatter.string(from: Date())
        let params = ["count" : count, "dayTime": dayTime] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8002/bookCityService/getPopularSearchFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
    
    // 获取热搜词
    func getMostlySearchFun(count: Int, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dayTime = dateFormatter.string(from: Date())
        let params = ["count" : count, "dayTime": dayTime] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8002/bookCityService/getMostlySearchFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
}

// 分析
extension GTNet {
    
    // 获取每日阅读目标
    func getReadTarget(failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let dataModel: GTAccountInfoDataModel? = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        let params = ["userId" : dataModel!.userId] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8004/collectService/getTargetMinuteFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
    
    // 上传每日目标
    func setReadTarget(minute: Int, failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let dataModel: GTAccountInfoDataModel? = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        let params = ["userId" : dataModel!.userId, "minute": minute] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8004/collectService/setTargetMinuteFun", httpMethod: .post, params: params) { (json) in
            success(json)
        } error: { (error) in
            failure(error)
        }
    }
    
    // 获取分析数据
    func getAnalyseData(failure: @escaping ((AnyObject)->()), success: @escaping ((AnyObject)->())) {
        let dataModel: GTAccountInfoDataModel? = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dayTime = dateFormatter.string(from: Date())
        let params = ["userId" : dataModel!.userId,  "dayTime": dayTime] as [String : Any]
        self.requestWith(url: "http://39.105.217.90:8004/collectService/getReadSightAnalyResFun", httpMethod: .post, params: params) { (json) in
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
