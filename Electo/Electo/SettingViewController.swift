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
    @IBOutlet var dataAllowedSwitch: UISwitch!
    
    var settingDelegate: SettingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSwitch()
        setSlider()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
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
        
        self.settingDelegate?.groupingChanged()
    }
    
    @IBAction func networkAllowSwitch(_ sender: UISwitch) {
        guard sender.isOn else {
            Constants.dataAllowed = false
            UserDefaults.standard.set(Constants.dataAllowed, forKey: "dataAllowed")
            UserDefaults.standard.synchronize()
            return
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let titleString  = "It will use network data"
        
        alertController.setValue(titleString.getAttributedString(),
                                 forKey: "attributedTitle")
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            Constants.dataAllowed = true
            
            UserDefaults.standard.set(Constants.dataAllowed, forKey: "dataAllowed")
            UserDefaults.standard.synchronize()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
            Constants.dataAllowed = false
            
            UserDefaults.standard.set(Constants.dataAllowed, forKey: "dataAllowed")
            UserDefaults.standard.synchronize()
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func setSwitch() {
        let dataAllowed: Bool = UserDefaults.standard.object(forKey: "dataAllowed") as? Bool ?? false
        dataAllowedSwitch.setOn(dataAllowed, animated: false)
    }
    
    func setSlider() {
        let timeIntervalBoundary: Double = UserDefaults.standard
            .object(forKey: "timeIntervalBoundary") as? Double ?? Double(GroupingInterval.level3.rawValue)
        slider.setValue(Float(timeIntervalBoundary), animated: false)
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        if indexPath == IndexPath.init(row: 1, section: 1) {
            let message = "Download The Best Photo Clean&Refine App."
            let url = URL(string: "https://naver.com")
            let activityViewController = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)
            activityViewController.excludedActivityTypes = [.airDrop, .addToReadingList, .copyToPasteboard]
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}
