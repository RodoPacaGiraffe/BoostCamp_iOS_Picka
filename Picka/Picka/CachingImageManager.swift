//
//  CachingImageManager.swift
//  Picka
//
//  Created by 임성훈 on 2017. 8. 24..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

class CachingImageManager: PHCachingImageManager {
    static let shared: CachingImageManager = CachingImageManager()
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector (stopCachingImagesForAllAssets),
                                               name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning,
                                                  object: nil)
    }
}
