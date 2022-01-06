//
//  GTBook.swift
//  GTRead
//
//  Created by YangJie on 2021/3/24.
//
import PDFKit

class GTBookCache {

    private var booksPageDataModel: GTPDFPageDataModel?
    private var index = 0
    private var page = 0
    
    static let shared = GTBookCache()
    private init() {}
    
    // 读取
    func getCacheBookPage(bookId: String) -> Int {
        let dataModel: GTAccountInfoDataModel? = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        // 获取PDF页码缓存
        self.booksPageDataModel = GTDiskCache.shared.getObjectData(String(dataModel!.userId) + "_page_cache")
        
        if self.booksPageDataModel != nil {
            var flag = false
            for i in 0..<(self.booksPageDataModel?.lists.count)! {
                if self.booksPageDataModel?.lists[i].bookId == bookId {
                    self.index = i
                    self.page = (self.booksPageDataModel?.lists[i].page)!
                    flag = true
                    break
                }
            }
            if flag == false {
                self.booksPageDataModel?.lists.append(GTPDFPageDataItem(bookId: bookId, page: 0))
            }
        } else {
            self.booksPageDataModel = GTPDFPageDataModel(lists: [GTPDFPageDataItem(bookId: bookId, page: 0)])
            self.page = 0
        }
        
        return self.page
    }
    
    // 保存
    func cacheBookPage(page: Int) {
        let dataModel: GTAccountInfoDataModel? = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        self.booksPageDataModel?.lists[self.index].page = page
        
        GTDiskCache.shared.saveObjectData(String(dataModel!.userId) + "_page_cache", value: self.booksPageDataModel)
    }
}
