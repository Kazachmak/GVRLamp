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
    
    
    @IBAction func close(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
    
    @IBAction func returnToMainView(_ sender: UIButton) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet var picker: UIPickerView!

    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var backArrowHeight: NSLayoutConstraint!
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var title = UILabel()
                if let view = view {
                       title = view as! UILabel
                 }
        title.font = UIFont.systemFont(ofSize: 23, weight: UIFont.Weight.medium)
               title.textColor = UIColor.black
               title.text =  pickerData[row]
               title.textAlignment = .center

           return title
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let currentLamp = lamp {
            currentLamp.sendCommand(command: .timer, value: [row]) // устанавливаем таймер на выбранное время
            switch row {
            
            case 1:
                currentLamp.timerTime = 60
            case 2:
                currentLamp.timerTime = 300
            case 3:
                currentLamp.timerTime = 600
            case 4:
                currentLamp.timerTime = 900
            case 5:
                currentLamp.timerTime = 1800
            case 6:
                currentLamp.timerTime = 2700
            case 7:
                currentLamp.timerTime = 3600 
            default:
                break
            }
            currentLamp.sendCommand(command: .timer_get, value: [0])
        }
        
        dismiss(animated: true) // закрываем view
    }

    @IBOutlet var invalidateTimerOut: UIButton!

    @IBAction func invalidateTimer(_ sender: UIButton) {
        if let currentLamp = lamp {
            currentLamp.sendCommand(command: .timer, value: [0])  //отключаем таймер
        }
        dismiss(animated: true) // закрываем view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backArrowHeight.constant += self.view.safeAreaTop - 20
        headerViewHeight.constant += self.view.safeAreaTop - 20
    }
}
