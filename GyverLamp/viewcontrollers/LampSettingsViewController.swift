//
//  AutoSwitchEffectViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 28.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit

class LampSettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var picker = UIPickerView()
    var lamp: LampDevice?
    var selectedEffects: [Bool]?
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
            intervalSec = row
            intervalOut.setTitle("\(intervalSec ?? 0)" + " сек", for: .normal)
            sendFavoriteMessage()
        } else {
            randomSec = row
            randomTimeOut.setTitle("\(randomSec ?? 0)" + " сек", for: .normal)
            sendFavoriteMessage()
        }
        picker.removeFromSuperview()
    }

    @IBOutlet var autoSwitchLabel: UILabel!

    @IBOutlet var alwaysAutoSwitchLabel: UILabel!

    @IBOutlet var intervalOut: UIButton!

    @IBOutlet var updatingLabelHeight: NSLayoutConstraint!

    @IBOutlet var messageLabel: UILabel!

    @IBOutlet var backArrowHeight: NSLayoutConstraint!

    @IBOutlet var headerViewHeight: NSLayoutConstraint!

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
        openSelector(.effects, selectedEffects: selectedEffects, lamp: lamp!)
    }

    @IBOutlet var randomTimeOut: UIButton!

    @IBOutlet var favOnOut: UISwitch!

    private func sendFavoriteMessage() {
        if let currentLamp = lamp {
            if let interval = intervalSec, let random = randomSec {
                var array = [favOnOut.isOn.convertToInt(), interval, random, favAlwaysOnOut.isOn.convertToInt()]
                if let effects = selectedEffects {
                    array.append(contentsOf: effects.convertToIntArray())
                    currentLamp.sendCommand(lamp: currentLamp, command: .fav_set, value: array)
                }
            }
        }
    }

    @IBAction func favOn(_ sender: UISwitch) {
        sendFavoriteMessage()
    }

    @IBOutlet var favAlwaysOnOut: UISwitch!

    @IBAction func favAlwaysOn(_ sender: UISwitch) {
        sendFavoriteMessage()
    }

    @IBAction func getEffectsFromLamp(_ sender: UISwitch) {
        if let currentLamp = lamp {
            currentLamp.getEffectsFromLamp(sender.isOn)
            if sender.isOn {
                showMessage(true, text: "Загружаем эффекты")
                var runCount = 0
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    if currentLamp.effectsFromLamp {
                        self.showMessage(true, text: "Эффекты загружены")
                        timer.invalidate()
                    }
                    runCount += 1
                    if runCount == 4 {
                        self.showMessage(true, text: "Не удалось загрузить эффекты")
                        self.getEffectsFromListOut.setOn(false, animated: true)
                        timer.invalidate()
                    }
                }
            } else {
                showMessage(false, text: "")
            }
        }
    }

    @IBOutlet var getEffectsFromListOut: UISwitch!

    @IBOutlet var openListOfEffectsOut: UIButton!

    func setListOfEffects(list: [Bool]) {
        selectedEffects = list
        if let effects = selectedEffects {
            openListOfEffectsOut.setTitle("\(effects.filter({ $0 == true }).count)", for: .normal)
        }
    }

    @IBOutlet var buttonOnLampOut: UISwitch!

    @IBAction func buttonOnLamp(_ sender: UISwitch) {
        if let currentLamp = lamp {
            if currentLamp.button ?? true {
                currentLamp.sendCommand(lamp: currentLamp, command: .button_off, value: [0])
            } else {
                currentLamp.sendCommand(lamp: currentLamp, command: .button_on, value: [0])
            }
        }
    }
    
    
    @IBAction func sendTextToLamp(_ sender: UIButton) {
        showInputDialog(title: "Введите текст",
                        subtitle: "Введите текст для отправки",
                        actionTitle: "Отправить",
                        cancelTitle: "Отмена",
                        inputPlaceholder: "Сообщение",
                        inputKeyboardType: .default, actionHandler:
                            { (input:String?) in
                                if let currentLamp = self.lamp{
                                    currentLamp.sendCommand(lamp: currentLamp, command: .txt, value: [0], valueTXT: input ?? "")
                                }
                            })
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

    @IBAction func close(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }

    @IBAction func returnToMainView(_ sender: UIButton) {
        view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }

    @IBOutlet var renameLampOut: UIButton!

    @IBOutlet var removeLampOut: UIButton!

    @IBAction func removeButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("deleteLamp"), object: lamp)
        lamp?.deleteLamp()
        dismiss(animated: true)
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

            if currentLamp.favorite?.components(separatedBy: " ")[1] == "1" {
                favOnOut.setOn(true, animated: false)
            }
            if currentLamp.favorite?.components(separatedBy: " ")[4] == "1" {
                favAlwaysOnOut.setOn(true, animated: false)
            }

            if currentLamp.effectsFromLamp {
                getEffectsFromListOut.setOn(true, animated: false)
            } else {
                getEffectsFromListOut.setOn(false, animated: false)
            }
            if let intervalSec = currentLamp.favorite?.components(separatedBy: " ")[2] {
                intervalOut.setTitle("\(intervalSec)" + " сек", for: .normal)
                self.intervalSec = Int(intervalSec)
            }
            if let randomSec = currentLamp.favorite?.components(separatedBy: " ")[3] {
                randomTimeOut.setTitle("\(randomSec)" + " сек", for: .normal)
                self.randomSec = Int(randomSec)
            }
            if currentLamp.button ?? true {
                buttonOnLampOut.setOn(true, animated: false)
            } else {
                buttonOnLampOut.setOn(false, animated: false)
            }
            let range = (currentLamp.favorite?.components(separatedBy: " ").count ?? 0) - 1
            if let arrayOfSelectedEffect = currentLamp.favorite?.components(separatedBy: " ")[5 ... range] {
                selectedEffects = [Bool](repeating: false, count: arrayOfSelectedEffect.count)
                for (index, element) in arrayOfSelectedEffect.enumerated() {
                    if element == "1" {
                        selectedEffects?[index] = true
                    }
                }
                openListOfEffectsOut.setTitle("\(selectedEffects?.filter({ $0 == true }).count ?? 0)", for: .normal)
            }
        } else {
            showMessage(true, text: "Обновляем информацию")
        }
    }
}
