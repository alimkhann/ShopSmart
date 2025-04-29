//
//  CacheManager.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 28/4/2025.
//

import Foundation
import UIKit

class CacheManager {
    
    static let instance = CacheManager()
    private init() {}
    
    var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 20
        return cache
    }()
    
    func saveImageToCache(image: UIImage, name: String) {
        imageCache.setObject(image, forKey: name as NSString)
        print("Added to cache")
    }
    
    func removeImageFromCache(name: String) {
        imageCache.removeObject(forKey: name as NSString)
        print("Removed from cache")
    }
    
    func getImageFromCache(name: String) -> UIImage? {
        return imageCache.object(forKey: name as NSString)
    }
}
