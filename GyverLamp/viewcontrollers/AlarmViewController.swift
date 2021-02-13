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
        openSelector(.days, selectedDays: selectedDays, lamp: lamp!)
    }

    @IBAction func openDawnList(_ sender: UITapGestureRecognizer) {
        openSelector(.dawn, selectedDawn: selectedDawn, lamp: lamp!)
    }

    @IBAction func returnToMainView(_ sender: UIButton) {
        view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }

    @IBOutlet var daysLabel: UILabel!

    @IBOutlet var dawnLabel: UILabel!

    @IBOutlet var backArrowHeight: NSLayoutConstraint!

    @IBOutlet var headerViewHeight: NSLayoutConstraint!

    @IBOutlet var hourLabel: UILabel!

    @IBOutlet var minLabel: UILabel!

    @IBOutlet var towDotsLabel: UILabel!

    @IBOutlet var constraitFortButton: NSLayoutConstraint!

    @IBOutlet var buttonHeight: NSLayoutConstraint!

    // включаем и выключаем будильник
    @IBAction func alarmOnButton(_ sender: UIButton) {
        if let currentLamp = lamp, selectedDays.contains(true) {
            if sender.titleLabel?.text == "Отключить будильник" {
                for element in [Int](1 ... 7) {
                    currentLamp.sendCommand(lamp: currentLamp, command: .alarm_off, value: [element])
                }
                alarmOnButtonOut.setTitle("Включить будильник", for: .normal)
            } else {
                let date = datePickerOut.date
                let calendar = Calendar.current
                let comp = calendar.dateComponents([.hour, .minute], from: date)
                let hour = comp.hour
                let minute = comp.minute
                for (index, element) in selectedDays.enumerated() {
                    if element {
                        currentLamp.sendCommand(lamp: currentLamp, command: .alarm, value: [index + 1, 60 * hour! + minute!])
                        currentLamp.sendCommand(lamp: currentLamp, command: .alarm_on, value: [index + 1])
                    }
                }
                currentLamp.sendCommand(lamp: currentLamp, command: .dawn, value: [(selectedDawn ?? 0) + 1])
                alarmOnButtonOut.setTitle("Отключить будильник", for: .normal)
            }
        }
    }

    @IBOutlet var alarmOnButtonOut: UIButton!

    @IBOutlet var datePickerOut: UIDatePicker!

    @IBAction func datePicker(_ sender: UIDatePicker) {
    }

    func setDawn(dawn: Int) {
        selectedDawn = dawn
        // рассвет
        let dawnList = ["Рассвет за 5 минут", "Рассвет за 10 минут", "Рассвет за 15 минут", "Рассвет за 20 минут   ", "Рассвет за 25 минут", "Рассвет за 30 минут", "Рассвет за 40 минут", "Рассвет за 50 минут", "Рассвет за 60 минут"]
        dawnLabel.text = dawnList[selectedDawn ?? 0]
    }

    func setDays(days: [Bool]) {
        selectedDays = days
        var daysArray: String = ""
        if selectedDays[0] {
            daysArray.append("Пн.")
        }
        if selectedDays[1] {
            daysArray.append("Вт.")
        }
        if selectedDays[2] {
            daysArray.append("Ср.")
        }
        if selectedDays[3] {
            daysArray.append("Чт.")
        }
        if selectedDays[4] {
            daysArray.append("Пт.")
        }
        if selectedDays[5] {
            daysArray.append("Сб.")
        }
        if selectedDays[6] {
            daysArray.append("Вс.")
        }
        daysLabel.text = daysArray
    }

    var lamp: LampDevice?

    @IBOutlet var setAlarmOut: UIButton!

    @IBAction func setAlarm(_ sender: UIButton) {
    }

    override func viewDidAppear(_ animated: Bool) {
        towDotsLabel.blink()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backArrowHeight.constant += view.safeAreaTop - 20
        headerViewHeight.constant += view.safeAreaTop - 20

        if UIScreen.main.bounds.height < 669 {
            constraitFortButton.constant = 10
            buttonHeight.constant = 50
        }

        if let currentLamp = lamp {
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
                selectedDawn = Int(String(dawn))
                setDawn(dawn: selectedDawn ?? 0)
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
                        alarmOnButtonOut.setTitle("Отключить будильник", for: .normal)
                    }
                }
                selectedDays = array
                setDays(days: selectedDays)
            }
        }
    }
}
