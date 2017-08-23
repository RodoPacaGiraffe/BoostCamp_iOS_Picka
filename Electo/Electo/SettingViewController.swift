//
//  SettingViewController.swift
//  Electo
//
//  Created by Alpaca on 2017. 8. 17..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {
    @IBOutlet private var slider: UISlider!
    @IBOutlet private var dataAllowedSwitch: UISwitch!
    @IBOutlet private var levelLabels: [UILabel]!
    
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
        if Locale.preferredLanguages.first == "ar" {
            levelLablesToArabic()
        }
        
        let timeIntervalBoundary: Double = UserDefaults.standard.object(forKey: "timeIntervalBoundary")
            as? Double ?? Double(GroupingInterval.level3.rawValue)
        
        slider.setValue(Float(timeIntervalBoundary), animated: false)
    }
    
    private func levelLablesToArabic() {
        levelLabels.forEach {
            guard let text = $0.text, let level = Int(text) else { return }
            $0.text = level.toArabic()
        }
    }
    
    @IBAction private func sliderValueChanged(_ sender: UISlider) {
        switch sender.value {
        case Clustering.interval1:
            sender.setValue(GroupingInterval.level1.rawValue, animated: true)
        case Clustering.interval2:
            sender.setValue(GroupingInterval.level2.rawValue, animated: true)
        case Clustering.interval3:
            sender.setValue(GroupingInterval.level3.rawValue, animated: true)
        case Clustering.interval4:
            sender.setValue(GroupingInterval.level4.rawValue, animated: true)
        default:
            sender.setValue(GroupingInterval.level5.rawValue, animated: true)
        }
        
        Constants.timeIntervalBoundary = Double(sender.value)
        
        UserDefaults.standard.set(Constants.timeIntervalBoundary, forKey: "timeIntervalBoundary")
        UserDefaults.standard.synchronize()
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
        let classifiedPhotoViewController = self.presentingViewController as? ClassifiedPhotoViewController
            ?? ClassifiedPhotoViewController()
        classifiedPhotoViewController.appearLoadingView()
        
        self.settingDelegate?.groupingChanged()

        dismiss(animated: true, completion: nil)
    }
}

