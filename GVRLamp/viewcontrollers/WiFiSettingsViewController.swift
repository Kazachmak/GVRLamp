//
//  WiFiSettingsViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 13.11.2021.
//  Copyright © 2021 Maksim Kazachkov. All rights reserved.
//

import UIKit

class WiFiSettingsViewController: UIViewController {
    var lamp: LampDevice?

    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBOutlet weak var saveButtonOut: UIButton!
    
    @IBOutlet var viewWithTextFileds: UIView!

    @IBOutlet var backArrowHeight: NSLayoutConstraint!

    @IBOutlet var headerViewHeight: NSLayoutConstraint!

    @IBOutlet var nameTextField: UITextField!

    @IBOutlet var passTestField: UITextField!

    @IBOutlet var timeoutTextField: UITextField!

    @IBOutlet weak var wifiLampSwitchOut: UISwitch!
    
    @IBOutlet weak var routerWifiSwitchOut: UISwitch!
    
    @IBOutlet weak var label1: UILabel!
    
    
    @IBOutlet weak var height1: NSLayoutConstraint!
    
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var height2: NSLayoutConstraint!
    
    
    @IBAction func close(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }

    @IBAction func hideShowPassword(_ sender: UIButton) {
        passTestField.hideShowPassword()
    }
    
    
    @IBAction func wifiLampSwitch(_ sender: UISwitch) {
        if sender.isOn{
            routerWifiSwitchOut.setOn(false, animated: true)
            viewWithTextFileds.isHidden = true
            label1.isHidden = false
            label2.isHidden = false
            height1.constant = 60
            height2.constant = 30
        }else{
            routerWifiSwitchOut.setOn(true, animated: true)
            viewWithTextFileds.isHidden = false
            label1.isHidden = true
            label2.isHidden = true
            height1.constant = 0
            height2.constant = 420
        }
    }
    
    @IBAction func routerWifiSwitch(_ sender: UISwitch) {
        if sender.isOn{
            wifiLampSwitchOut.setOn(false, animated: true)
            viewWithTextFileds.isHidden = false
            label1.isHidden = true
            label2.isHidden = true
            height1.constant = 0
            height2.constant = 420
        }else{
            wifiLampSwitchOut.setOn(true, animated: true)
            viewWithTextFileds.isHidden = true
            label1.isHidden = false
            label2.isHidden = false
            height1.constant = 60
            height2.constant = 30
        }
    }
    

    @IBAction func saveButon(_ sender: UIButton) {
        if viewWithTextFileds.isHidden {
            delay(delayTime: 0.0, completionHandler: { [self] in
                lamp?.sendCommand(command: .blank, value: [0], valueTXT: "reset=wifi")
            })
            delay(delayTime: 0.05, completionHandler: { [self] in
                lamp?.sendCommand(command: .blank, value: [0], valueTXT: "esp_mode=0")
            })
            delay(delayTime: 0.05, completionHandler: { [self] in
                lamp?.sendCommand(command: .txt, value: [0], valueTXT: "esp_mode=0")
            })
            let mode: ModeOfSearch = .searchInSpotMode
            lamps.removeLamp(lamp!)
            performSegue(withIdentifier: "searchAndAdd3", sender: mode)
            
        } else {
            if let name = nameTextField.text, let pass = passTestField.text, var timeout = timeoutTextField.text {
                if (name != "") && (pass != "") {
                    if timeout == "" {
                        timeout = "60"
                    }
                    UserDefaults.standard.set(name, forKey: "wifiName")
                    UserDefaults.standard.set(pass, forKey: "wifiPass")
                   
                    
                    delay(delayTime: 0.0, completionHandler: { [self] in
                        lamp?.sendCommand(command: .blank, value: [0], valueTXT: "ssid=" + name)
                    })
                    delay(delayTime: 0.05, completionHandler: { [self] in
                        lamp?.sendCommand(command: .blank, value: [0], valueTXT: "passw=" + pass)
                    })
                    delay(delayTime: 0.1, completionHandler: { [self] in
                        lamp?.sendCommand(command: .blank, value: [0], valueTXT: "timeout=" + timeout)
                    })
                    delay(delayTime: 0.15, completionHandler: { [self] in
                        lamp?.sendCommand(command: .blank, value: [0], valueTXT: "esp_mode=1")
                    })
                    delay(delayTime: 0.2, completionHandler: { [self] in
                        lamp?.sendCommand(command: .txt, value: [0], valueTXT: "esp_mode=1")
                    })
                    lamps.removeLamp(lamp!)
                    let mode: ModeOfSearch = .searchInRouterMode
                    performSegue(withIdentifier: "searchAndAdd3", sender: mode)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchAndAdd3" {
            let vc = segue.destination as? SearchAndAddLampViewController
            
            if let text = nameTextField.text{
                vc?.label = text
            }
            vc?.modeOfSearch = sender as! ModeOfSearch
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        titleLabel.adjustsFontSizeToFitWidth = true
        backArrowHeight.constant += view.safeAreaTop - 20
        headerViewHeight.constant += view.safeAreaTop - 20
        if let wifiName = UserDefaults.standard.string(forKey: "wifiName"){
            nameTextField.text = wifiName
        }
        if let wifiPass = UserDefaults.standard.string(forKey: "wifiPass"){
            passTestField.text = wifiPass
        }
        nameTextField.setLeftPaddingPoints(20.0)
        passTestField.setLeftPaddingPoints(20.0)
        timeoutTextField.setLeftPaddingPoints(20.0)
        timeoutTextField.keyboardType = .decimalPad
        saveButtonOut.titleLabel?.adjustsFontSizeToFitWidth = true
        if let espMode = lamp?.espMode {
            viewWithTextFileds.isHidden = !espMode
            if !espMode {
                wifiLampSwitchOut.setOn(true, animated: false)
                routerWifiSwitchOut.setOn(false, animated: false)
            } else {
                wifiLampSwitchOut.setOn(false, animated: false)
                routerWifiSwitchOut.setOn(true, animated: false)
                label1.isHidden = true
                label2.isHidden = true
                height1.constant = 0
            }
        }
    }
}
