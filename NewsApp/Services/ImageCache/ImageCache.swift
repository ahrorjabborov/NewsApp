//
//  ImageCache.swift
//  NewsApp
//
//  Created by Ahror Jabborov on 1/23/25.
//

import UIKit

// not needed anymore
final class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        // cache.countLimit = 100
    }
    
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
