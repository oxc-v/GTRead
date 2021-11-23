//
//  GTDiskCache.swift
//  GTRead
//
//  Created by Dev on 2021/10/26.
//

import UIKit
import SwiftUI

final class GTDiskCache {
    
    private let ioQueue: DispatchQueue
    private let ioQueueName = "com.GTDisk.Cache.IoQueue."
    private let defualtFolder = "com.gtread.www"
    private var fileManager: FileManager!
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    let diskCachePath: String
    
    
    // 采用单例模式
    static let shared = GTDiskCache()
    
    private init() {
        // 初始化解码器和编码器
        decoder = JSONDecoder()
        encoder = JSONEncoder()
        ioQueue = DispatchQueue(label: ioQueueName, attributes: [])
        
        //获取沙盒 cache 目录路径
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        diskCachePath = (paths.first! as NSString).appendingPathComponent(defualtFolder)
        self.fileManager = FileManager.default
        
        ioQueue.sync { () -> Void in
            self.createDirectory(diskCachePath)
        }
    }
    
    // 缓存图片
    func saveImageWithData(_ key: String, _ data: Data) {
        // 拼接路径
        let userFolder = UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? ""
        let imageFolder = "Image"
        let path_1 = (diskCachePath as NSString).appendingPathComponent(userFolder)
        let path_2 = (path_1 as NSString).appendingPathComponent(imageFolder)
        let path_3 = (path_2 as NSString).appendingPathComponent(key)
        
        ioQueue.async {
            self.createDirectory(path_2)
            let ok = self.fileManager.createFile(atPath: path_3, contents: data, attributes: nil)
            if ok == false {
                print("saveImageWithData error: Save image failure")
            }
        }
    }
    
    // 获取图片
    func getImageWithData(_ key: String, completed: (Data?)->()) {
        // 拼接路径
        let userFolder = UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? ""
        let imageFolder = "Image"
        let path_1 = (diskCachePath as NSString).appendingPathComponent(userFolder)
        let path_2 = (path_1 as NSString).appendingPathComponent(imageFolder)
        let path_3 = (path_2 as NSString).appendingPathComponent(key)
        
        if self.fileManager.fileExists(atPath: path_3) {
            if let data = self.fileManager.contents(atPath: path_3) {
                completed(data)
            } else {
                completed(nil)
                print("getImageWithData error: data is nil")
            }
        } else {
            completed(nil)
            print("getImageWithData error: not found file")
        }
    }
     
    func getImageWithPath(_ key: String) -> String? {
        // 拼接路径
        let userFolder = UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? ""
        let imageFolder = "Image"
        let path_1 = (diskCachePath as NSString).appendingPathComponent(userFolder)
        let path_2 = (path_1 as NSString).appendingPathComponent(imageFolder)
        let path_3 = (path_2 as NSString).appendingPathComponent(key)
        
        if self.fileManager.fileExists(atPath: path_3) {
            return path_3
        } else {
            return nil
        }
    }
    
    // 缓存不同的界面数据
    func saveViewObject<T: Encodable>(_ key: String, value: T?) {
        // 拼接路径
        let userFolder = UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? ""
        let viewFolder = "ViewData"
        let path_1 = (diskCachePath as NSString).appendingPathComponent(userFolder)
        let path_2 = (path_1 as NSString).appendingPathComponent(viewFolder)
        let path_3 = (path_2 as NSString).appendingPathComponent(key)
        
        ioQueue.async {
            self.createDirectory(path_2)
            if let data = try? self.encoder.encode(value) {
                do {
                    try data.write(to: URL(fileURLWithPath: path_3), options: NSData.WritingOptions.atomic)
                }catch let err {
                    print("saveViewObject error:\(err)")
                }
            } else {
                print("saveViewObject: data is nil")
            }
        }
    }
    
    // 获取界面对象数据
    func getViewObject<T: Decodable>(_ key: String) -> T? {
        // 拼接路径
        let userFolder = UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? ""
        let shelfFolder = "ViewData"
        let path_1 = (diskCachePath as NSString).appendingPathComponent(userFolder)
        let path_2 = (path_1 as NSString).appendingPathComponent(shelfFolder)
        let path_3 = (path_2 as NSString).appendingPathComponent(key)
        
        if self.fileManager.fileExists(atPath: path_3){
            let data = self.fileManager.contents(atPath: path_3)
            if let obj = try? self.decoder.decode(T.self, from: data!) {
                return obj
            } else {
                print("getViewObject error: obj is nil")
                return nil
            }
        } else {
            print("getViewObject error: not found")
            return nil
        }
    }
    
    // 删除对象文件
    func delViewObject(_ key: String) {
        // 拼接路径
        let userFolder = UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? ""
        let shelfFolder = "ViewData"
        let path_1 = (diskCachePath as NSString).appendingPathComponent(userFolder)
        let path_2 = (path_1 as NSString).appendingPathComponent(shelfFolder)
        let path_3 = (path_2 as NSString).appendingPathComponent(key)
        
        if self.fileManager.fileExists(atPath: path_3){
            try? self.fileManager.removeItem(atPath: path_3)
        } else {
            print("delViewObject error: not found")
        }
    }
    
    // 获取PDF URL
    func getPDF(_ fileName: String) -> URL? {
        // 拼接路径
        let userFolder = UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? ""
        let pdfFolder = "PDFDocument"
        let path_1 = (diskCachePath as NSString).appendingPathComponent(userFolder)
        let path_2 = (path_1 as NSString).appendingPathComponent(pdfFolder)
        let path_3 = (path_2 as NSString).appendingPathComponent(fileName + ".pdf")
        
        // 判断文件是否存在
        if self.fileManager.fileExists(atPath: path_3) {
            return URL(fileURLWithPath: path_3)
        } else {
            return nil
        }
    }
    
    // 删除PDF
    func deletePDF(_ key: String) {
        // 拼接路径
        let userFolder = UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? ""
        let pdfFolder = "PDFDocument"
        let path_1 = (diskCachePath as NSString).appendingPathComponent(userFolder)
        let path_2 = (path_1 as NSString).appendingPathComponent(pdfFolder)
        let path_3 = (path_2 as NSString).appendingPathComponent(key + ".pdf")
        
        if self.fileManager.fileExists(atPath: path_3){
            try? self.fileManager.removeItem(atPath: path_3)
        } else {
            print("delViewObject error: not found")
        }
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
    
    // 创建目录
    func createDirectory(_ path: String) {
        if !self.fileManager.fileExists(atPath: path) {
            do {
                try self.fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
                print("GTDiskCache: 创建目录失败！")
            }
        }
    }
}
