//
//  WiFiSettingsViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 13.11.2021.
//  Copyright © 2021 Maksim Kazachkov. All rights reserved.
//

import UIKit

class WiFiSettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var lamp: LampDevice?

    var picker = UIPickerView()

    let pickerArray = ["Использовать WiFi сеть лампы", "Использовать роутер"]

    @IBOutlet var viewWithTextFileds: UIView!

    @IBOutlet var backArrowHeight: NSLayoutConstraint!

    @IBOutlet var headerViewHeight: NSLayoutConstraint!

    @IBOutlet var nameTextField: UITextField!

    @IBOutlet var passTestField: UITextField!

    @IBOutlet var timeoutTextField: UITextField!

    @IBOutlet var saveButtonOut: UIButton!

    @IBAction func close(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }

   

    @IBAction func saveButon(_ sender: UIButton) {
        if viewWithTextFileds.isHidden {
            delay(delayTime: 0.0, completionHandler: { [self] in
                lamp?.sendCommand(command: .txt, value: [0], valueTXT: "reset=wifi")
            })
            delay(delayTime: 0.05, completionHandler: { [self] in
                lamp?.sendCommand(command: .txt, value: [0], valueTXT: "esp_mode=0")
            })
            dismiss(animated: true)
        } else {
            if let name = nameTextField.text, let pass = passTestField.text, var timeout = timeoutTextField.text {
                if (name != "") && (pass != "") {
                    if timeout == "" {
                        timeout = "60"
                    }
                    delay(delayTime: 0.0, completionHandler: { [self] in
                        lamp?.sendCommand(command: .txt, value: [0], valueTXT: "ssid=" + name)
                    })
                    delay(delayTime: 0.05, completionHandler: { [self] in
                        lamp?.sendCommand(command: .txt, value: [0], valueTXT: "passw=" + pass)
                    })
                    delay(delayTime: 0.1, completionHandler: { [self] in
                        lamp?.sendCommand(command: .txt, value: [0], valueTXT: "timeout=" + timeout)
                    })
                    delay(delayTime: 0.15, completionHandler: { [self] in
                        lamp?.sendCommand(command: .txt, value: [0], valueTXT: "esp_mode=1")
                    })
                    dismiss(animated: true)
                }
            }
        }
    }

    @IBAction func selectConnectionTypeButton(_ sender: UIButton) {
        picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect(x: 0.0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        view.addSubview(picker)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerArray[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            viewWithTextFileds.isHidden = true
            saveButtonOut.setTitle("Переключить лампу в режим точки доступа", for: .normal)
            saveButtonOut.setImage(nil, for: .normal)
        } else {
            viewWithTextFileds.isHidden = false
            saveButtonOut.setTitle("Сохранить", for: .normal)
            saveButtonOut.setImage(UIImage(named: "edit.png"), for: .normal)
        }
        picker.removeFromSuperview()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        backArrowHeight.constant += view.safeAreaTop - 20
        headerViewHeight.constant += view.safeAreaTop - 20
        saveButtonOut.imageView?.contentMode = .scaleAspectFit
        nameTextField.setLeftPaddingPoints(20.0)
        passTestField.setLeftPaddingPoints(20.0)
        timeoutTextField.setLeftPaddingPoints(20.0)
        timeoutTextField.keyboardType = .decimalPad
        saveButtonOut.titleLabel?.adjustsFontSizeToFitWidth = true
        if let espMode = lamp?.espMode {
            viewWithTextFileds.isHidden = espMode
            if !espMode {
                saveButtonOut.setTitle("Сохранить", for: .normal)
                saveButtonOut.setImage(UIImage(named: "edit.png"), for: .normal)
            } else {
                saveButtonOut.setTitle("Переключить лампу в режим точки доступа", for: .normal)
                saveButtonOut.setImage(nil, for: .normal)
            }
        }
    }
}
