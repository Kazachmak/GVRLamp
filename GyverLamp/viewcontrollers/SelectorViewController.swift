//
//  SelectorViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 01.12.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit

class SelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var flag: selectorFlag = .days

    var selectedDays = [Bool](repeating: false, count: 7)
    var selectedDay: Int?
    var selectedDawn: Int?
    var lamp: LampDevice?

    // дни будильника
    let days = [everyMonday, everyTuesday, everyWednesday, everyThursday, everyFriday, everySaturday, everySunday]

    // рассвет
    let dawnList = [dawnin5Minutes, dawnin10Minutes, dawnin15Minutes, dawnin20Minutes, dawnin25Minutes, dawnin30Minutes, dawnin40Minutes, dawnin50Minutes, dawnin60Minutes]

    @IBOutlet var mainLabel: UILabel!

    @IBOutlet var tableView: UITableView!

    @IBOutlet var backArrowHeight: NSLayoutConstraint!

    @IBOutlet var headerViewHeight: NSLayoutConstraint!

    private func sendFavoriteMessage() {
        if let currentLamp = lamp {
            let array = currentLamp.favorite?.components(separatedBy: " ")[1...4]
            var intArray = array?.compactMap { Int($0) }
            let effects = currentLamp.selectedEffects
            intArray?.append(contentsOf: effects.convertToIntArray())
            currentLamp.sendCommand(command: .fav_set, value: intArray!)
        }
    }
    
    
    @IBAction func close(_ sender: UITapGestureRecognizer) {
        if flag == .effects{
            if let currentLamp = lamp{
                if let vc = parent as? LampSettingsViewController{
                    vc.setListOfEffects(list: currentLamp.selectedEffects)
                }else{
                    self.sendFavoriteMessage()
                }
            }
        }
        view.removeFromSuperview()
        removeFromParent()
    }

   

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch flag {
        case .dawn: return dawnList.count
        case .days: return days.count
        case .effects: return lamp?.listOfEffects.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selector", for: indexPath) as! SelectorTableViewCell
        switch flag {
        case .effects:
            cell.day.text = lamp?.listOfEffects[indexPath.row].components(separatedBy: ",")[0]
            if let currentLamp = lamp {
                if currentLamp.selectedEffects[indexPath.row] {
                    cell.selector.image = UIImage(named: "selector.png")!
                } else {
                    cell.selector.image = nil
                }
            }
        case .days:
            cell.day.text = days[indexPath.row]
            if selectedDays[indexPath.row] {
                cell.selector.image = UIImage(named: "selector.png")!
            } else {
                cell.selector.image = nil
            }
        case .dawn:
            cell.day.text = dawnList[indexPath.row]
            if selectedDawn == indexPath.row + 1 {
                cell.selector.image = UIImage(named: "selector.png")!
            } else {
                cell.selector.image = nil
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch flag {
        case .effects:
            if let currentLamp = lamp {
                currentLamp.selectedEffects[indexPath.row] = !currentLamp.selectedEffects[indexPath.row]
            }
        case .days:
            selectedDays[indexPath.row] = !selectedDays[indexPath.row]
            let vc = parent as! AlarmViewController
            vc.setDays(days: selectedDays)
        case .dawn:
            selectedDawn = indexPath.row + 1
            let vc = parent as! AlarmViewController
            vc.setDawn(selectedDawn ?? 1)
        }
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backArrowHeight.constant += view.safeAreaTop - 20
        headerViewHeight.constant += view.safeAreaTop - 20
        tableView.tableFooterView = UIView()
        switch flag {
        case .dawn: mainLabel.text = dawnFor
        case .days: mainLabel.text = repeatAlarm
        case .effects: mainLabel.text = selectEffects
        }
    }
}
