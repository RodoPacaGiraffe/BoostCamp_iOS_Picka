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
        
        setTickStackView()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        switch sender.value {
        case 1..<1.5:
            sender.setValue(1.0, animated: true)
        case 1.5..<2.5:
            sender.setValue(2.0, animated: true)
        case 2.5..<3.5:
            sender.setValue(3.0, animated: true)
        case 3.5..<4.5:
            sender.setValue(4.0, animated: true)
        default:
            sender.setValue(5.0, animated: true)
        }
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
    
    func setTickStackView() {
        let sliderWidth: CGFloat = slider.frame.width
        guard let tickWidth: CGFloat = tickStackView.subviews.first?.frame.width else { return }
        tickStackView.spacing = (sliderWidth - tickWidth * 5) / 4 - 1
    }
}
