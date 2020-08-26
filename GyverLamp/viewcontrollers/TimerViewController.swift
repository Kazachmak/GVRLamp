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
    let pickerData = ["Не выключать","1 минуту","5 минут","10 минут","15 минут","30 минут","45 минут","60 минут"]
    
    @IBOutlet weak var picker: UIPickerView!
    
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
        if let currentLamp = lamp{
            currentLamp.sendCommand(lamp: currentLamp, command: .timer, value: row)
        }
        
        self.dismiss(animated: true, completion: nil)
       }
    
    
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var invalidateTimerOut: UIButton!
    
    @IBAction func invalidateTimer(_ sender: UIButton) {
        if let currentLamp = lamp{
            currentLamp.sendCommand(lamp: currentLamp, command: .timer, value: 0)
            self.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    
    @IBOutlet weak var closeTimerOut: UIButton!
    
    @IBAction func closeTimer(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerLabel.adjustsFontSizeToFitWidth = true
        invalidateTimerOut.addBoxShadow()
        closeTimerOut.addBoxShadow()
        
    }
    

    

}
