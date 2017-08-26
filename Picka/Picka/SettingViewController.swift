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
        let dataAllowed: Bool = UserDefaults.standard.object(forKey: UserDefaultsKey.networkDataAllowed) as? Bool ?? true
        dataAllowedSwitch.setOn(dataAllowed, animated: false)
    }
    
    private func setSlider() {
        let timeIntervalBoundary: Double = UserDefaults.standard.object(forKey: UserDefaultsKey.timeIntervalBoundary)
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
        
        SettingConstants.timeIntervalBoundary = Double(sender.value)
        
        UserDefaults.standard.set(SettingConstants.timeIntervalBoundary, forKey: UserDefaultsKey.timeIntervalBoundary)
        UserDefaults.standard.synchronize()
        
        tableView.isScrollEnabled = true
    }
    
    @IBAction private func networkAllowSwitch(_ sender: UISwitch) {
        switch sender.isOn {
        case true:
            let title = NSLocalizedString(LocalizationKey.useCellularData, comment: "")
            let alertController = UIAlertController(title: title, message: nil,
                                                    preferredStyle: .alert)
            
            let okAction = UIAlertAction(
                title: NSLocalizedString(LocalizationKey.ok, comment: ""),
                style: .default,
                handler: { _ in
                    SettingConstants.networkDataAllowed = true
                    
                    UserDefaults.standard.set(SettingConstants.networkDataAllowed, forKey: UserDefaultsKey.networkDataAllowed)
                    UserDefaults.standard.synchronize()
            })
            
            let cancelAction = UIAlertAction(
                title: NSLocalizedString(LocalizationKey.cancel, comment: ""),
                style: .cancel,
                handler: { _ in
                    sender.setOn(false, animated: true)
                    SettingConstants.networkDataAllowed = false
                    
                    UserDefaults.standard.set(SettingConstants.networkDataAllowed, forKey: UserDefaultsKey.networkDataAllowed)
                    UserDefaults.standard.synchronize()
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
        case false:
            SettingConstants.networkDataAllowed = false
            
            UserDefaults.standard.set(SettingConstants.networkDataAllowed, forKey: UserDefaultsKey.networkDataAllowed)
            UserDefaults.standard.synchronize()
        }
    }
    

    @IBAction private func modalDismiss(_ sender: UIBarButtonItem) {
        self.settingDelegate?.timeIntervalBoundaryChanged()
        self.dismiss(animated: true, completion: nil)
    }
}

