//
//  LaunchScreenViewController.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 12..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos

fileprivate struct Constants {
    static let loadingView: String = "LoadingView"
}

class LoadingView: UIView {
    @IBOutlet private var indicatorView: UIActivityIndicatorView!
    @IBOutlet private var loadingImageView: UIImageView!
    
    class func instanceFromNib(frame: CGRect) -> LoadingView {
        guard let loadingView = UINib(nibName: Constants.loadingView, bundle: nil)
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
