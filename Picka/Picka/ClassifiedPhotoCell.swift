//
//  ImageCell.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 5..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos

fileprivate struct Constants {
    static let deleteConfirmationView = "deleteConfirmationView"
    static let maximumImageViewCount: Int = 4
    static let lastImageAlpha: CGFloat = 0.5
    static let imageContainerViewRoundBorderDegree: CGFloat = 16.0
    static let imageContainerViewBackgroundColor: UIColor = UIColor(red: 243/255,
                                                                    green: 243/255,
                                                                    blue: 243/255,
                                                                    alpha: 1)
}

class ClassifiedPhotoCell: UITableViewCell {
    @IBOutlet private(set) var imageViews: [UIImageView]!
    @IBOutlet private var numberOfPhotosLabel: UILabel!
    @IBOutlet private var locationLabel: UILabel!
    @IBOutlet private var imageContainerView: UIView!
    @IBOutlet private var imageStackView: UIStackView!
    @IBOutlet private var moreImagesLabel: UILabel!
    
    private(set) var requestIDs: [PHImageRequestID] = []
    
    private var cellImages: [UIImage] = [] {
        didSet {
            addPhotoImagesToStackView(photoImages: cellImages)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.subviews.forEach { subview in
            let typeString = String(describing: type(of: subview))
            guard typeString == Constants.deleteConfirmationView else { return }
            
            guard let target = imageContainerView else { return }
        
            subview.frame.size.height = target.frame.size.height
            subview.frame.origin.y = target.frame.origin.y
        }
    }
    
    func addPhotoImagesToStackView(photoImages: [UIImage]) {
        moreImagesLabel.isHidden = true
        
        for index in photoImages.indices {
            guard index < Constants.maximumImageViewCount else {
                setLabel()
                break
            }
            
            imageViews[index].image = photoImages[index]
        }
        
        imageContainerView.makeRoundBorder(degree: Constants.imageContainerViewRoundBorderDegree)
        imageContainerView.backgroundColor = Constants.imageContainerViewBackgroundColor
    }
    
    func setLabel() {
        guard let lastIamgeView = imageViews.last else { return }
        lastIamgeView.image = lastIamgeView.image?.alpha(Constants.lastImageAlpha)
        
        let numberOfMoreImages = cellImages.count - Constants.maximumImageViewCount
        
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            if Locale.preferredLanguages.first == "ar" {
                moreImagesLabel.text = "\(numberOfMoreImages.toArabic())+"
            } else {
                moreImagesLabel.text = "\(numberOfMoreImages)+"
            }
        } else {
            moreImagesLabel.text = "+\(numberOfMoreImages)"
        }
       
        moreImagesLabel.isHidden = false
    }
    
    func setLocationLabelText(with locationText: String) {
        locationLabel.text = locationText
    }
    
    func clearStackView() {
        imageViews.forEach {
            $0.image = nil
        }

        moreImagesLabel.isHidden = true
        locationLabel.text = nil
    }
}

