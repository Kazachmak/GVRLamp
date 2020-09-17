//
//  AlarmViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 26.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit

class AlarmViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // дни будильника
    let days = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]

    // рассвет
    let dawnList = ["Рассвет за\n5 минут", "Рассвет за\n10 минут", "Рассвет за\n15 минут", "Рассвет за\n20 минут", "Рассвет за\n25 минут", "Рассвет за\n30 минут", "Рассвет за\n40 минут", "Рассвет за\n50 минут", "Рассвет за\n60 минут"]
    var selectedDay: Int?
    var selectedDawn: Int?

    @IBOutlet var daysCollctionView: UICollectionView!

    @IBOutlet var dawnCollectionView: UICollectionView!

    // включаем и выключаем будильник
    @IBAction func alarmOnButton(_ sender: UIButton) {
        if let currentLamp = lamp, selectedDay != nil {
            if sender.titleLabel?.text == "Будильник включен" {
                currentLamp.sendCommand(lamp: currentLamp, command: .alarm_off, value: [selectedDay!])
                alarmOnButtonOut.setTitle("Будильник выключен", for: .normal)
                alarmOnButtonOut.setTitleColor(.black, for: .normal)
            } else {
                currentLamp.sendCommand(lamp: currentLamp, command: .alarm_on, value: [selectedDay!])
                let date = datePickerOut.date
                let calendar = Calendar.current
                let comp = calendar.dateComponents([.hour, .minute], from: date)
                let hour = comp.hour
                let minute = comp.minute
                print(60 * hour! + minute!)
                currentLamp.sendCommand(lamp: currentLamp, command: .alarm, value: [selectedDay!, 60 * hour! + minute!])
                alarmOnButtonOut.setTitleColor(.red, for: .normal)
                alarmOnButtonOut.setTitle("Будильник включен", for: .normal)
            }
        }
    }

    @IBOutlet var alarmOnButtonOut: UIButton!

    @IBOutlet var datePickerOut: UIDatePicker!

    @IBAction func datePicker(_ sender: UIDatePicker) {
    }

    // получаем будильник для выбранного дня
    private func getAlarm(day: Int) {
        if let currentLamp = lamp {
            if currentLamp.alarm?.components(separatedBy: " ")[day] == "1" {
                datePickerOut.setDate(currentLamp.alarm?.components(separatedBy: " ")[day + 7].getTimeFromString() ?? Date(), animated: true)
            }

            if currentLamp.alarm?.components(separatedBy: " ")[day] == "1" {
                alarmOnButtonOut.setTitleColor(.red, for: .normal)
                alarmOnButtonOut.setTitle("Будильник включен", for: .normal)

            } else {
                alarmOnButtonOut.setTitle("Будильник выключен", for: .normal)
                alarmOnButtonOut.setTitleColor(.black, for: .normal)
            }
        }
    }

    // выбираем какой будильник настраиваем и время рассвета
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let currentLamp = lamp {
            switch collectionView {
            case daysCollctionView:
                selectedDay = indexPath.row + 1
                getAlarm(day: indexPath.row + 1)
                selectedDawn = currentLamp.dawn

                daysCollctionView.reloadData()
                dawnCollectionView.reloadData()
                dawnCollectionView.selectItem(at: IndexPath(row: selectedDawn ?? 0, section: 0), animated: true, scrollPosition: .right)
            case dawnCollectionView:
                currentLamp.sendCommand(lamp: currentLamp, command: .dawn, value: [indexPath.row + 1])
                selectedDawn = indexPath.row + 1
                dawnCollectionView.reloadData()
            default: break
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case daysCollctionView: return days.count
        case dawnCollectionView: return dawnList.count
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case daysCollctionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "day", for: indexPath) as! DaysCollectionViewCell
            cell.dayLabel.text = days[indexPath.row]
            if selectedDay == indexPath.row + 1 {
                cell.setBlackBorder(enabled: true)
            } else {
                cell.setBlackBorder(enabled: false)
            }
            cell.addBoxShadow()
            return cell
        case dawnCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dawn", for: indexPath) as! DawnCollectionViewCell
            cell.dawnLabel.text = dawnList[indexPath.row]
            cell.addBoxShadow()
            if selectedDawn == indexPath.row + 1 {
                cell.setBlackBorder(enabled: true)
            } else {
                cell.setBlackBorder(enabled: false)
            }
            return cell

        default: let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dawn", for: indexPath) as! DawnCollectionViewCell
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 60)
    }

    var lamp: LampDevice?

    @IBOutlet var setAlarmOut: UIButton!

    @IBAction func setAlarm(_ sender: UIButton) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setAlarmOut.addBoxShadow()

        if let currentLamp = lamp {
            currentLamp.sendCommand(lamp: currentLamp, command: .alarm_on, value: [0]) // здесь запрашиваем состояние будильников
        }
    }
}
