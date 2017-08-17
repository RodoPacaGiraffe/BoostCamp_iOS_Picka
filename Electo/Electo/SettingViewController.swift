//
//  SettingViewController.swift
//  Electo
//
//  Created by Alpaca on 2017. 8. 17..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {
    
    @IBOutlet var slider: UISlider!
    @IBOutlet var tickStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setTickStackView()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        switch sender.value {
        case Clustering.interval1:
            sender.setValue(30.0, animated: true)
        case Clustering.interval2:
            sender.setValue(60.0, animated: true)
        case Clustering.interval3:
            sender.setValue(90.0, animated: true)
        case Clustering.interval4:
            sender.setValue(120.0, animated: true)
        default:
            sender.setValue(150.0, animated: true)
        }
        
        Constants.timeIntervalBoundary = Double(sender.value)
    }
    
    @IBAction func networkAllowSwitch(_ sender: UISwitch) {
        print(sender.state)
        if sender.isOn {
            let alertController = UIAlertController(title: "", message: "It will use network data", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                Constants.dataAllowed = true
            })
            let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: { (action) in
                Constants.dataAllowed = false
            })
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            print("on")
            present(alertController, animated: true, completion: nil)
        } else {
            print("off")
            Constants.dataAllowed = false
        }
    }
    
//    func setTickStackView() {
//        let sliderWidth: CGFloat = slider.frame.width
//        guard let tickWidth: CGFloat = tickStackView.subviews.first?.frame.width else { return }
//        tickStackView.spacing = (sliderWidth - tickWidth * 5) / 4 + 1
//    }
}
