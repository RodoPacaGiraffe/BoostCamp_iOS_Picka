//
//  SettingViewController.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 17..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {
    @IBOutlet private var slider: UISlider!
    @IBOutlet private var dataAllowedSwitch: UISwitch!
    
    var settingDelegate: SettingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSwitch()
        setSlider()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    private func setSwitch() {
        let dataAllowed: Bool = UserDefaults.standard.object(forKey: "dataAllowed") as? Bool ?? true
        
        dataAllowedSwitch.setOn(dataAllowed, animated: false)
    }
    
    private func setSlider() {
        let timeIntervalBoundary: Double = UserDefaults.standard.object(forKey: "timeIntervalBoundary")
            as? Double ?? Double(GroupingInterval.level2.rawValue)
        
        slider.setValue(Float(timeIntervalBoundary), animated: false)
    }
    
    @IBAction private func sliderValueChanged(_ sender: UISlider) {
        tableView.isScrollEnabled = false
        
        switch sender.value {
        case Clustering.interval1:
            sender.value = GroupingInterval.level1.rawValue
        case Clustering.interval2:
            sender.value = GroupingInterval.level2.rawValue
        default:
            sender.value = GroupingInterval.level3.rawValue
        }
        
        Constants.timeIntervalBoundary = Double(sender.value)
        
        UserDefaults.standard.set(Constants.timeIntervalBoundary, forKey: "timeIntervalBoundary")
        UserDefaults.standard.synchronize()
        
        tableView.isScrollEnabled = true
    }
    
    @IBAction private func networkAllowSwitch(_ sender: UISwitch) {
        switch sender.isOn {
        case true:
            let title = NSLocalizedString("UseiCloud", comment: "")
            let alertController = UIAlertController(title: title, message: nil,
                                                    preferredStyle: .alert)
            
            let okAction = UIAlertAction(
                title: NSLocalizedString("OK", comment: ""),
                style: .default,
                handler: { _ in
                    Constants.dataAllowed = true
                    
                    UserDefaults.standard.set(Constants.dataAllowed, forKey: "dataAllowed")
                    UserDefaults.standard.synchronize()
            })
            
            let cancelAction = UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: { _ in
                    sender.setOn(false, animated: true)
                    Constants.dataAllowed = false
                    
                    UserDefaults.standard.set(Constants.dataAllowed, forKey: "dataAllowed")
                    UserDefaults.standard.synchronize()
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
        case false:
            Constants.dataAllowed = false
            
            UserDefaults.standard.set(Constants.dataAllowed, forKey: "dataAllowed")
            UserDefaults.standard.synchronize()
        }
    }
    

    @IBAction private func modalDismiss(_ sender: UIBarButtonItem) {
        self.settingDelegate?.groupingChanged()

        dismiss(animated: true, completion: nil)
    }
}

