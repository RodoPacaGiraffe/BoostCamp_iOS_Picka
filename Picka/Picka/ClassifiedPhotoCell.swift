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
    struct ImageContainerView {
        static let roundBorderDegree: CGFloat = 16.0
        static let backgroundColor: UIColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1.0)
    }
    
    static let deleteConfirmationView = "deleteConfirmationView"
    static let maximumImageViewCount: Int = 4
    static let lastImageAlpha: CGFloat = 0.5
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
            addCellImagesToStackView(cellImages: cellImages)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.subviews.forEach { subview in
            let typeString = String(describing: type(of: subview))
            guard typeString == Constants.deleteConfirmationView else { return }
        
            subview.frame.size.height = imageContainerView.frame.size.height
            subview.frame.origin.y = imageContainerView.frame.origin.y
        }
    }
    
    func setCellImages(with images: [UIImage]) {
        cellImages = images
    }
    
    func addCellImagesToStackView(cellImages: [UIImage]) {
        moreImagesLabel.isHidden = true
        
        for index in cellImages.indices {
            guard index < Constants.maximumImageViewCount else {
                setLabel()
                break
            }
            
            imageViews[index].image = cellImages[index]
        }
        
        imageContainerView.makeRoundBorder(degree: Constants.ImageContainerView.roundBorderDegree)
        imageContainerView.backgroundColor = Constants.ImageContainerView.backgroundColor
    }
    
    func setLabel() {
        guard let lastIamgeView = imageViews.last else { return }
        lastIamgeView.image = lastIamgeView.image?.alpha(Constants.lastImageAlpha)
        
        let numberOfMoreImages = cellImages.count - Constants.maximumImageViewCount
        
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            if Locale.preferredLanguages.first == Language.arabic {
                moreImagesLabel.text = "\(numberOfMoreImages.toArabic())+"
            } else {
                moreImagesLabel.text = "\(numberOfMoreImages)+"
            }
        } else {
            moreImagesLabel.text = "+\(numberOfMoreImages)"
        }
       
        moreImagesLabel.isHidden = false
    }
    
    func setNumberOfPhotosLabelText(with numberOfPhotosString: String) {
        numberOfPhotosLabel.text = numberOfPhotosString
    }
    
    func setLocationLabelText(with locationString: String) {
        locationLabel.text = locationString
    }
    
    func clearStackView() {
        imageViews.forEach {
            $0.image = nil
        }

        moreImagesLabel.isHidden = true
        locationLabel.text = nil
    }
    
    func appendRequestID(requestID: PHImageRequestID) {
        requestIDs.append(requestID)
    }
    
    func removeAllrequestIDs() {
        requestIDs.removeAll()
    }
}

