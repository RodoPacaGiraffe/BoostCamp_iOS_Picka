//
//  LaunchScreenViewController.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 12..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos

class LoadingView: UIView {
    @IBOutlet private var indicatorView: UIActivityIndicatorView!
    @IBOutlet private var loadingImageView: UIImageView!
    
    class func instanceFromNib(frame: CGRect) -> LoadingView {
        guard let loadingView = UINib(nibName: "LoadingView", bundle: nil)
            .instantiate(withOwner: nil, options: nil).first as? LoadingView else {
            return LoadingView()
        }
        loadingView.frame = frame
        
        return loadingView
    }
    
    func stopIndicatorAnimating() {
        indicatorView?.stopAnimating()
    }
}
