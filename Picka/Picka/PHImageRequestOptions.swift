//
//  PHImageOptions.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 22..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

extension PHImageRequestOptions {
    func setImageRequestOptions(networkAccessAllowed: Bool, synchronous: Bool,
                                deliveryMode: PHImageRequestOptionsDeliveryMode,
                                progressHandler:  PHAssetImageProgressHandler?) {
        self.isNetworkAccessAllowed = networkAccessAllowed
        self.isSynchronous = synchronous
        self.deliveryMode = deliveryMode
        self.progressHandler = progressHandler
    }
}
