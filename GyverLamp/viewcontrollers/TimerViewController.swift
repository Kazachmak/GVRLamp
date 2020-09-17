//
//  TimerViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 24.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var lamp: LampDevice?
    let pickerData = ["Не выключать", "1 минуту", "5 минут", "10 минут", "15 минут", "30 минут", "45 минут", "60 минут"]

    @IBOutlet var picker: UIPickerView!

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let currentLamp = lamp {
            currentLamp.sendCommand(lamp: currentLamp, command: .timer, value: [row]) // устанавливаем таймер на выбранное время
        }

        dismiss(animated: true, completion: nil) // закрываем view
    }

    @IBOutlet var timerLabel: UILabel!

    @IBOutlet var invalidateTimerOut: UIButton!

    @IBAction func invalidateTimer(_ sender: UIButton) {
        if let currentLamp = lamp {
            currentLamp.sendCommand(lamp: currentLamp, command: .timer, value: [0])  //отключаем таймер
            dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        timerLabel.adjustsFontSizeToFitWidth = true
        invalidateTimerOut.addBoxShadow()
    }
}
