//
//  ImageCell.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 5..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

class ClassifiedPhotoCell: UITableViewCell {
    @IBOutlet var numberOfPhotosLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var imageContainerView: UIView!
    @IBOutlet var imageStackView: UIStackView!
    @IBOutlet var imageViews: [UIImageView]!
    @IBOutlet var moreImagesLabel: UILabel!
    
    var cellImages: [UIImage] = .init() {
        didSet {
            addPhotoImagesToStackView(photoImages: cellImages)
        }
    }
    
    override func layoutSubviews() {
        self.subviews.forEach { subview in
            let typeString = String(describing: type(of: subview))
            guard typeString == Constants.deleteConfirmationView else { return }
            
            guard let target = imageStackView else { return }
        
            subview.frame.size.height = target.frame.size.height
            subview.frame.origin.y = target.frame.origin.y
        }
    }
    
    func update(date: String, location: String?) {
        numberOfPhotosLabel.text = date
        locationLabel.text = location
    }
    
    func addPhotoImagesToStackView(photoImages: [UIImage]) {
        moreImagesLabel.isHidden = true
        for index in photoImages.indices {
            guard index < Constants.maximumImageView else {
                setLabel()
                break
            }
            imageViews[index].image = photoImages[index]
        }
        self.imageContainerView.makeRoundBorder(degree: 16.0)
        self.imageContainerView.backgroundColor = UIColor(red: 243/255,
                                                                 green: 243/255,
                                                                 blue: 243/255,
                                                                 alpha: 1)
    }
    
    func setLabel() {
        guard let lastIamgeView = imageViews.last else { return }
        lastIamgeView.image = lastIamgeView.image?.alpha(0.5)
        
        let numOfMoreImages = cellImages.count - Constants.maximumImageView
        moreImagesLabel.text = "+\(numOfMoreImages)"
        moreImagesLabel.isHidden = false
    }
    
    func clearStackView() {
        imageViews.forEach {
            $0.image = nil
        }

        moreImagesLabel.isHidden = true
        locationLabel.text = nil
    }
}

