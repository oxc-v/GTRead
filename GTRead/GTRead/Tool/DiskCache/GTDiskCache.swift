//
//  GTDiskCache.swift
//  GTRead
//
//  Created by Dev on 2021/10/26.
//

import UIKit

// 在cache下创建目录管理
enum CacheFor: String{
    case Object = "GTObject"    // 对象缓存
    case PDF = "GTPDF"          // PDF文件缓存
    case Image = "GTImage"      // 图片缓存
}

// 目录名
enum CacheFolder: String {
    case PDFFolder = "PDFDocuments"
    case ObjectFolder = "UserData"
    case ImageFolder = "Image"
}

final class GTDiskCache {
    
    private let ioQueue: DispatchQueue
    private let ioQueueName = "com.GTDisk.Cache.IoQueue."
    private let defualtFolder = "com.gtread.www"
    private var fileManager: FileManager!
    private var storeType: CacheFor // 存储类型
    private let cacheFolderName: String // 缓存目录
    var diskCachePath: String   // 缓存位置
    
    
    // 采用单例模式
    static let sharedCachePDF = GTDiskCache(type: .PDF)
    static let sharedCacheImage = GTDiskCache(type: .Image)
    static let sharedCacheObject = GTDiskCache(type: .Object)
    
    private init(type: CacheFor) {
        self.storeType = type
        switch type {
        case .Object:
            cacheFolderName = CacheFolder.ObjectFolder.rawValue
        case .PDF:
            cacheFolderName = CacheFolder.PDFFolder.rawValue
        case .Image:
            cacheFolderName = CacheFolder.ImageFolder.rawValue
        }
        
        ioQueue = DispatchQueue(label: ioQueueName + type.rawValue, attributes: [])
        
        //获取缓存目录
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        diskCachePath = (paths.first! as NSString).appendingPathComponent(defualtFolder)
        diskCachePath = (diskCachePath as NSString).appendingPathComponent(cacheFolderName)
        
        ioQueue.sync { () -> Void in
            // 创建对象文件夹
            self.fileManager = FileManager.default
            if !self.fileManager.fileExists(atPath: diskCachePath) {
                do {
                    try self.fileManager.createDirectory(atPath: self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
                } catch _ {
                    print("GTDiskCache: 文件创建失败！")
                }
            }
        }
    }
    
    // 存储PDF文件
    func savePDF(_ data: Data?, path: String, completed: ((Bool)->())? = nil) {
        ioQueue.async {
            if let data = data {
                if self.fileManager.createFile(atPath: self.cachePathForKey(path), contents: data, attributes: nil) {
                    completed?(true)
                } else {
                    completed?(false)
                }
            }
        }
    }
    
    // 存储Image文件
    func saveImage(_ data: Data?, path: String, completed: ((Bool)->())? = nil) {
        ioQueue.async {
            if let data = data {
                if self.fileManager.createFile(atPath: self.cachePathForKey(path), contents: data, attributes: nil) {
                    completed?(true)
                } else {
                    completed?(false)
                }
            }
        }
    }
    
    // 存储对象
    func saveObject(_ key: String, value: Any?, completed: ((Bool)->())? = nil) {
        ioQueue.async{
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            coder.encode(value, forKey: key)
            let data = coder.encodedData

            do {
                try data.write(to: URL(fileURLWithPath: self.cachePathForKey(key)), options: NSData.WritingOptions.atomic)
                completed?(true)
            }catch let err {
                print(err)
                completed?(false)
            }
        }
    }
    
    // 获取对象数据
    func getObject(_ key: String, completed: ((_ obj: Any?)->())?) {
        DispatchQueue.global().async { () -> Void in
            if self.fileManager.fileExists(atPath: self.cachePathForKey(key)){
                let data = NSMutableData(contentsOfFile: self.cachePathForKey(key))
                do {
                    let unArchiver = try NSKeyedUnarchiver(forReadingFrom: data! as Data)
                    let obj = unArchiver.decodeObject(forKey: key)
                    completed?(obj)
                } catch let err {
                    print("getObject error:\(err)")
                    completed?(nil)
                }
            }else{
                completed?(nil)
            }
        }
    }
    
    // 读取PDF
    func getPDF(_ path: String, completed: ((_ data: Data?)->())?){
        DispatchQueue.global().async { () -> Void in
            if let data = try? Data(contentsOf: URL(fileURLWithPath: self.cachePathForKey(path))){
                completed?(data)
            } else {
                completed?(nil)
            }
        }
    }
    
    // 读取Image
    func getImage(_ path: String, completed: ((_ data: Data?)->())?){
        DispatchQueue.global().async { () -> Void in
            if let data = try? Data(contentsOf: URL(fileURLWithPath: self.cachePathForKey(path))){
                completed?(data)
            } else {
                completed?(nil)
            }
        }
    }
}

extension GTDiskCache {
    func cachePathForKey(_ key: String) -> String {
        var fileName: String = ""
        if self.storeType == CacheFor.PDF {
            fileName = key + ".pdf"
        } else if self.storeType == CacheFor.Image {
            fileName = key + ".png"
        } else {
            fileName = key
        }
        
        return (diskCachePath as NSString).appendingPathComponent(fileName)
    }
}

extension GTDiskCache {
    // 判断文件是否已经存在
    func isExist(_ fileName: String) -> Bool {
        if self.fileManager.fileExists(atPath: self.cachePathForKey(fileName)) {
            return true
        } else {
            return false
        }
    }
    
    // 获取文件完整的URL
    func getFileURL(_ fileName: String) -> String {
        return self.cachePathForKey(fileName)
    }
}

extension GTDiskCache {
    
    // 获取缓存目录大小
    func fileSizeOfCache()-> Double {
        
        // 取出cache文件夹目录 缓存文件都在这个目录下
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first

        // 取出文件夹下所有文件数组
        let fileArr = self.fileManager.subpaths(atPath: cachePath!)

        //快速枚举出所有文件名 计算文件大小
        var size = 0
        for file in fileArr! {
            // 把文件名拼接到路径中
            let path = (cachePath! as NSString).appendingPathComponent(file)

            // 取出文件属性
            let floder = try! self.fileManager.attributesOfItem(atPath: path)
            for (abc, bcd) in floder {
                // 累加文件大小
                if abc == FileAttributeKey.size {
                    size += (bcd as AnyObject).integerValue
                }
            }
        }

        let mm = Double(size) / 1024 / 1024

        return mm
    }
    
    // 清除缓存
    func clearCache(){
        let cacheURL =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory( at: cacheURL, includingPropertiesForKeys: nil, options: [])
            for file in directoryContents {
                do {
                    try fileManager.removeItem(at: file)
                }
                catch let error as NSError {
                    debugPrint("Ooops! Something went wrong: \(error)")
                }

            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}
