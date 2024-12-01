//
//  AlarmViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 26.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit

class AlarmViewController: UIViewController {
    var selectedDays: [Bool] = [Bool](repeating: false, count: 7)

    var selectedDawn: Int?

    @IBAction func close(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }

    @IBAction func openDaysList(_ sender: UITapGestureRecognizer) {
        openSelector(.days, selectedDays: selectedDays, lamp: lamps.mainLamp!)
    }

    @IBAction func openDawnList(_ sender: UITapGestureRecognizer) {
        openSelector(.dawn, selectedDawn: selectedDawn, lamp: lamps.mainLamp!)
    }

    @IBOutlet var daysLabel: UILabel!

    @IBOutlet var dawnLabel: UILabel!

    @IBOutlet var backArrowHeight: NSLayoutConstraint!

    @IBOutlet var headerViewHeight: NSLayoutConstraint!

    @IBOutlet var hourLabel: UILabel!

    @IBOutlet var minLabel: UILabel!

    @IBOutlet var towDotsLabel: UILabel!

    @IBOutlet var constraitFortButton: NSLayoutConstraint!

    // включаем и выключаем будильник

    @IBOutlet var alarmOnOffSwitch: UISwitch!

    @IBAction func alarmOnOffSwitchAction(_ sender: UISwitch) {
        alarmOnOff()
    }

    func alarmOnOff() {
        if let currentLamp = lamps.mainLamp {
            // let date = datePickerOut.date
            // let calendar = Calendar.current
            // let comp = calendar.dateComponents([.hour, .minute], from: date)
            // let hour = comp.hour
            // let minute = comp.minute

            if !alarmOnOffSwitch.isOn {
                for (index, _) in selectedDays.enumerated() {
                    delay(delayTime: Double(index) * 0.05, completionHandler: {
                        // currentLamp.sendCommand(command: .alarm, value: [index + 1, 60 * hour! + minute!])
                        currentLamp.sendCommand(command: .alarm_off, value: [index + 1])
                    })
                }
            } else {
                for (index, element) in selectedDays.enumerated() {
                    delay(delayTime: Double(index) * 0.05, completionHandler: {
                        if element {
                            // currentLamp.sendCommand(command: .alarm, value: [index + 1, 60 * hour! + minute!])
                            currentLamp.sendCommand(command: .alarm_on, value: [index + 1])
                        }
                    })
                }
            }
        }
    }

    @IBOutlet var datePickerOut: UIDatePicker!

    @IBAction func datePicker(_ sender: UIDatePicker) {
        if let currentLamp = lamps.mainLamp {
            let date = datePickerOut.date
            let calendar = Calendar.current
            let comp = calendar.dateComponents([.hour, .minute], from: date)
            let hour = comp.hour
            let minute = comp.minute
            for (index, _) in selectedDays.enumerated() {
                delay(delayTime: Double(index) * 0.05, completionHandler: {
                    currentLamp.sendCommand(command: .alarm, value: [index + 1, 60 * hour! + minute!])
                })
            }
        }
    }

    func setDawn(_ dawn: Int) {
        selectedDawn = dawn
        if let currentLamp = lamps.mainLamp {
            currentLamp.sendCommand(command: .dawn, value: [selectedDawn ?? 1])
        }
        // рассвет
        let dawnList = [dawnin5Minutes, dawnin10Minutes, dawnin15Minutes, dawnin20Minutes, dawnin25Minutes, dawnin30Minutes, dawnin40Minutes, dawnin50Minutes, dawnin60Minutes]
        dawnLabel.text = dawnList[(selectedDawn ?? 1) - 1]
    }

    func setDays(days: [Bool]) {
        selectedDays = days
        let date = datePickerOut.date
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour, .minute], from: date)
        let hour = comp.hour
        let minute = comp.minute
        if let currentLamp = lamps.mainLamp {
            for (index, element) in selectedDays.enumerated() {
                delay(delayTime: Double(index) * 0.05, completionHandler: {
                    if element {
                        currentLamp.sendCommand(command: .alarm, value: [index + 1, 60 * hour! + minute!])
                        if self.alarmOnOffSwitch.isOn {
                            currentLamp.sendCommand(command: .alarm_on, value: [index + 1])
                        }

                    } else {
                        if self.alarmOnOffSwitch.isOn {
                            currentLamp.sendCommand(command: .alarm_off, value: [index + 1])
                        }
                    }
                })
            }
        }
        var daysArray: String = ""
        if selectedDays[0] {
            daysArray.append(mo)
        }
        if selectedDays[1] {
            daysArray.append(tu)
        }
        if selectedDays[2] {
            daysArray.append(we)
        }
        if selectedDays[3] {
            daysArray.append(th)
        }
        if selectedDays[4] {
            daysArray.append(fr)
        }
        if selectedDays[5] {
            daysArray.append(sa)
        }
        if selectedDays[6] {
            daysArray.append(su)
        }
        if daysArray.isEmpty {
        }
        daysLabel.text = daysArray
    }

    override func viewDidAppear(_ animated: Bool) {
        towDotsLabel.blink()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backArrowHeight.constant += view.safeAreaTop - 20
        headerViewHeight.constant += view.safeAreaTop - 20
        if let currentLamp = lamps.mainLamp {
            if let time = currentLamp.currentTime {
                let formatter1 = DateFormatter()
                formatter1.dateFormat = "HH"
                let formatter2 = DateFormatter()
                formatter2.dateFormat = "mm"
                Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [self] _ in
                    hourLabel.text = formatter1.string(from: time)
                    minLabel.text = formatter2.string(from: time)
                }
                hourLabel.text = formatter1.string(from: time)
                minLabel.text = formatter2.string(from: time)
            }
            if let alarms = currentLamp.alarm?.components(separatedBy: " ") {
                let dawn = alarms[15]
                setDawn(Int(dawn) ?? 1)
                let days = alarms[1 ..< 8]
                let times = alarms[8 ..< 15]
                var array: [Bool] = []
                for (index, element) in days.enumerated() {
                    if element == "0" {
                        array.append(false)
                    } else {
                        array.append(true)
                        let timeArray = Array(times)
                        datePickerOut.setDate(timeArray[index].getTimeFromString(), animated: true)
                        alarmOnOffSwitch.setOn(true, animated: false)
                    }
                }

                if array.allSatisfy({ $0 == false }) {
                    let calendar = Calendar.current
                    let date = Date()
                    let day = calendar.component(.weekday, from: date)
                    array[day - 1] = true
                    selectedDays = array
                } else {
                    selectedDays = array
                }

                setDays(days: selectedDays)
            }
        }
    }
}
