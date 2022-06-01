//
//  AutoSwitchEffectViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 28.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit
// import LanguageManager_iOS

class LampSettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var picker = UIPickerView()
    var lamp: LampDevice?
    var intervalSec: Int?
    var randomSec: Int?
    var senderTag: Int?

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 360
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if senderTag == 1 {
            if row > 2 {
                intervalSec = row
            } else {
                intervalSec = 3
            }
            intervalOut.setTitle("\(intervalSec ?? 0)" + sec, for: .normal)
            sendFavoriteMessage()
        } else {
            randomSec = row
            randomTimeOut.setTitle("\(randomSec ?? 0)" + sec, for: .normal)
            sendFavoriteMessage()
        }
        picker.removeFromSuperview()
    }

    @IBOutlet var favoriteEffectView: UIView!

    @IBOutlet var favoriteViewHeight: NSLayoutConstraint!

    @IBOutlet var effectsSetLabel: UILabel!

    @IBOutlet var autoSwitchLabel: UILabel!

    @IBOutlet var alwaysAutoSwitchLabel: UILabel!

    @IBOutlet var doNotForgetLampWhenConnectionIsLost: UISwitch!

    @IBOutlet var intervalOut: UIButton!

    @IBOutlet var updatingLabelHeight: NSLayoutConstraint!

    @IBOutlet var messageLabel: UILabel!

    @IBOutlet var backArrowHeight: NSLayoutConstraint!

    @IBOutlet var headerViewHeight: NSLayoutConstraint!

    @IBAction func changeLanguageButton(_ sender: UIButton) {
        let alert = UIAlertController(title: сhooselanguage, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "English", style: .default, handler: { _ in
            UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            self.showAlertAboutNeedToRestart()
        }))
        alert.addAction(UIAlertAction(title: "Русский", style: .default, handler: { _ in
            UserDefaults.standard.set(["ru"], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            self.showAlertAboutNeedToRestart()
        }))
        alert.addAction(UIAlertAction(title: "Українська", style: .default, handler: { _ in
            UserDefaults.standard.set(["uk"], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            self.showAlertAboutNeedToRestart()
        }))
        alert.addAction(UIAlertAction(title: closePopUp, style: .default, handler: { _ in
        }))
        present(alert, animated: true, completion: nil)
    }

    func openPickerView(_ tag: Int) {
        picker.removeFromSuperview()
        picker = UIPickerView()
        picker.delegate = self
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        if tag == 1 {
            picker.selectRow(intervalSec ?? 0, inComponent: 0, animated: false)
        } else {
            picker.selectRow(randomSec ?? 0, inComponent: 0, animated: false)
        }

        view.addSubview(picker)
    }

    @IBAction func openIntervalPicker(_ sender: UITapGestureRecognizer) {
        senderTag = 1
        openPickerView(1)
    }

    @IBAction func openRandomPicker(_ sender: UITapGestureRecognizer) {
        senderTag = 2
        openPickerView(2)
    }

    @IBAction func openEffectsList(_ sender: UITapGestureRecognizer) {
        openSelector(.effects, lamp: lamp!)
    }

    @IBOutlet var randomTimeOut: UIButton!

    @IBOutlet var favOnOut: UISwitch!

    private func sendFavoriteMessage(favoriteAlways: Bool = false) {
        if let currentLamp = lamp {
            if let interval = intervalSec, let random = randomSec {
                var array: [Int] = []
                if favoriteAlways {
                    array = [favOnOut.isOn.convertToInt(), interval, random, 1]
                } else {
                    array = [favOnOut.isOn.convertToInt(), interval, random, favAlwaysOnOut.isOn.convertToInt()]
                }

                let effects = currentLamp.selectedEffects
                array.append(contentsOf: effects.convertToIntArray())
                currentLamp.sendCommand(command: .fav_set, value: array)
            }
        }
    }

    @IBAction func favOn(_ sender: UISwitch) {
        sendFavoriteMessage(favoriteAlways: true)
        if sender.isOn{
            favoriteEffectView.isHidden = false
            favoriteViewHeight.constant = 206
        }else{
            favoriteViewHeight.constant = 24
            favoriteEffectView.isHidden = true
        }
    }

    @IBOutlet var favAlwaysOnOut: UISwitch!

    @IBAction func favAlwaysOn(_ sender: UISwitch) {
        sendFavoriteMessage()
    }

    @IBAction func doNotForgetLampWhenConnectionLostAction(_ sender: UISwitch) {
        lamp?.doNotForgetTheLampWhenTheConnectionIsLost = sender.isOn
    }
    
    
    @IBAction func getEffectsFromLamp(_ sender: UISwitch) {
        if let currentLamp = lamp {
            currentLamp.getEffectsFromLamp(sender.isOn)
            if sender.isOn {
                showMessage(true, text: effectsIsLoading)
                var runCount = 0
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    if currentLamp.effectsFromLamp {
                        self.showMessage(true, text: effectLoaded)
                        timer.invalidate()
                    }
                    runCount += 1
                    if runCount == 4 {
                        self.showMessage(true, text: failedToLoadEffects)
                        self.getEffectsFromListOut.setOn(false, animated: true)
                        timer.invalidate()
                    }
                }
            } else {
                showMessage(false, text: "")
            }
        }
    }

    @IBOutlet var commonBrightOut: UISwitch!

    @IBAction func commonBright(_ sender: UISwitch) {
        if sender.isOn {
            lamp?.commonBright = true
        } else {
            lamp?.commonBright = false
        }
    }

    @IBOutlet var getEffectsFromListOut: UISwitch!

    @IBOutlet var openListOfEffectsOut: UIButton!

    func setListOfEffects(list: [Bool]) {
        lamp?.selectedEffects = list
        if let effects = lamp?.selectedEffects {
            openListOfEffectsOut.setTitle("\(effects.filter({ $0 == true }).count)", for: .normal)
        }
        sendFavoriteMessage()
    }

    @IBOutlet var buttonOnLampOut: UISwitch!

    @IBAction func buttonOnLamp(_ sender: UISwitch) {
        if let currentLamp = lamp {
            if currentLamp.button ?? true {
                currentLamp.sendCommand(command: .button_off, value: [0])
            } else {
                currentLamp.sendCommand(command: .button_on, value: [0])
            }
        }
    }

    @IBAction func sendTextToLamp(_ sender: UIButton) {
        showInputDialog(title: enterText,
                        subtitle: enterTextForSending,
                        actionTitle: sendText,
                        cancelTitle: cancelSendText,
                        inputPlaceholder: messageToSend,
                        inputKeyboardType: .default, actionHandler: { (input: String?) in
                            if let currentLamp = self.lamp {
                                currentLamp.sendCommand(command: .txt, value: [0], valueTXT: input ?? "")
                            }
                        })
    }

    @IBAction func openWeb(_ sender: UIButton) {
        if let currentLamp = lamp {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "web") as! WebViewViewController
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            vc.lamp = currentLamp
            present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func renameLamp(_ sender: UIButton) {
        if let currentLamp = lamp {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "rename") as! RenameViewController
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            vc.lamp = currentLamp
            present(vc, animated: true, completion: nil)
        }
    }

    @IBOutlet var openWiFiSettingsOut: UIButton!

    @IBAction func openWiFiSettings(_ sender: UIButton) {
        if let currentLamp = lamp {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "wi-fi") as! WiFiSettingsViewController
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            vc.lamp = currentLamp
            print(currentLamp.hostIP)
            present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func close(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }

    @IBOutlet var renameLampOut: UIButton!

    @IBOutlet var removeLampOut: UIButton!

    @IBAction func removeButton(_ sender: UIButton) {
        if let currentLamp = lamp {
            lamps.removeLamp(currentLamp)
            dismiss(animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backArrowHeight.constant += view.safeAreaTop - 20
        headerViewHeight.constant += view.safeAreaTop - 20
        picker.dataSource = self
        randomTimeOut.titleLabel?.adjustsFontSizeToFitWidth = true
        intervalOut.titleLabel?.adjustsFontSizeToFitWidth = true
        renameLampOut.imageView?.contentMode = .scaleAspectFit
        removeLampOut.imageView?.contentMode = .scaleAspectFit
        NotificationCenter.default.addObserver(self, selector: #selector(updateInterface), name: Notification.Name("updateFavorite"), object: nil)
        if let currentLamp = lamp {
            currentLamp.updateFavoriteStatus(lamp: currentLamp)
        }
        autoSwitchLabel.adjustsFontSizeToFitWidth = true
        alwaysAutoSwitchLabel.adjustsFontSizeToFitWidth = true
        updateInterface()
        favoriteViewHeight.constant = 24
        favoriteEffectView.isHidden = true
    }

    private func showMessage(_ show: Bool, text: String) {
        if show {
            UIView.transition(with: view, duration: 1, options: .transitionCrossDissolve, animations: {
                self.updatingLabelHeight.constant = 24
                self.messageLabel.text = text
            })
        } else {
            UIView.transition(with: view, duration: 1, options: .transitionCrossDissolve, animations: {
                self.updatingLabelHeight.constant = 0
            })
        }
    }

    @objc func updateInterface() {
        if let currentLamp = lamp {
            showMessage(false, text: "")
            doNotForgetLampWhenConnectionIsLost.setOn(currentLamp.doNotForgetTheLampWhenTheConnectionIsLost, animated: false)
            commonBrightOut.setOn(currentLamp.commonBright, animated: false)

            if currentLamp.espMode {
                openWiFiSettingsOut.setTitle(wifiRouter, for: .normal)
            } else {
                openWiFiSettingsOut.setTitle(wifiRouterLamp, for: .normal)
            }

            if currentLamp.favorite?.components(separatedBy: " ")[1] == "1" {
                favOnOut.setOn(true, animated: false)

                favoriteEffectView.isHidden = false
                favoriteViewHeight.constant = 180

            } else {
                favoriteViewHeight.constant = 24
                favoriteEffectView.isHidden = true
            }

            if currentLamp.favorite?.components(separatedBy: " ")[4] == "1" {
                favAlwaysOnOut.setOn(true, animated: false)
            }

            getEffectsFromListOut.setOn(currentLamp.effectsFromLamp, animated: false)
            
            if let intervalSec = currentLamp.favorite?.components(separatedBy: " ")[2] {
                if (Int(intervalSec) ?? 0) > 2 {
                    self.intervalSec = Int(intervalSec)
                } else {
                    self.intervalSec = 3
                }
                intervalOut.setTitle("\(intervalSec) " + sec, for: .normal)
            }
            if let randomSec = currentLamp.favorite?.components(separatedBy: " ")[3] {
                randomTimeOut.setTitle("\(randomSec) " + sec, for: .normal)
                self.randomSec = Int(randomSec)
            }
            if currentLamp.button ?? true {
                buttonOnLampOut.setOn(true, animated: false)
            } else {
                buttonOnLampOut.setOn(false, animated: false)
            }

            openListOfEffectsOut.setTitle("\(currentLamp.selectedEffects.filter({ $0 == true }).count)", for: .normal)

        } else {
            showMessage(true, text: updatingInformation)
        }
    }
}
