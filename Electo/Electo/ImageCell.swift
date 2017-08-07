//
//  ImageCell.swift
//  Electo
//
//  Created by Alpaca on 2017. 8. 5..
//  Copyright © 2017년 임성훈. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    
    var imageAssets: [ImageAssetData] = []
    var imageViews: [UIImageView] = .init()
    
    var addNum: Int = .init()
    
    func setImages() {
        // Initialize the cell
        for imageView in imageViews {
            imageView.removeFromSuperview()
        }
        imageViews.removeAll()
        
//        setStackView()
        
        let imageView: UIImageView = .init()
        for imageAsset in imageAssets {
            imageView.image = imageAsset.image
            imageView.contentMode = .scaleAspectFit
            imageView.sizeThatFits(CGSize(width: 50, height: 50))
            
            stackView.addArrangedSubview(imageView)
            addNum += 1
            imageViews.append(imageView)
        }
        print("Add Images \(addNum)tiems")
        addNum = 0
    }
    
//    func setStackView() {
//        stackView.axis = .horizontal
//        stackView.distribution = .fillEqually
//        stackView.alignment = .center
//        stackView.spacing = 10.0
//        
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        self.contentView.addSubview(stackView)
//        NSLayoutConstraint.init(item: stackView, attribute: .topMargin, relatedBy: .equal, toItem: superview, attribute: .topMargin, multiplier: 1, constant: 0).isActive = true
//        NSLayoutConstraint.init(item: stackView, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0).isActive = true
//        NSLayoutConstraint.init(item: stackView, attribute: .bottomMargin, relatedBy: .equal, toItem: superview, attribute: .bottomMargin, multiplier: 1, constant: 0).isActive = true
//        NSLayoutConstraint.init(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
//    }
    
    func setDateLabel(creationDate: Date) {
        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = "yy년-MM월-dd일"
        let dateText = dateFormatter.string(from: creationDate)
        
        self.dateLabel.text = dateText
    }
    
    func setLocationLabel(location: String) {
        self.locationLabel.text = location
    }
}
