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
    lazy var selectedEffects = [Bool](repeating: false, count: self.lamp?.listOfEffects.count ?? 26)
    var selectedDay: Int?
    var selectedDawn: Int?
    var lamp: LampDevice?

    // дни будильника
    let days = ["Каждый понедельник", "Каждый вторник", "Каждую среду", "Каждый четверг", "Каждую пятница", "Каждую суббота", "Каждую воскресенье"]

    // рассвет
    let dawnList = ["Рассвет за 5 минут", "Рассвет за 10 минут", "Рассвет за 15 минут", "Рассвет за 20 минут", "Рассвет за 25 минут", "Рассвет за 30 минут", "Рассвет за 40 минут", "Рассвет за 50 минут", "Рассвет за 60 минут"]

    
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    
    @IBOutlet weak var backArrowHeight: NSLayoutConstraint!
    
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    
    
    @IBAction func close(_ sender: UITapGestureRecognizer) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    
    @IBAction func returnToMainView(_ sender: UIButton) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
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
            cell.day.text = lamp?.listOfEffects[indexPath.row]
            if selectedEffects[indexPath.row] {
                cell.selector.image = UIImage(named: "selector.png")!
            } else {
                cell.selector.image = nil
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
            if selectedDawn == indexPath.row{
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
            selectedEffects[indexPath.row] = !selectedEffects[indexPath.row]
            let vc = parent as! LampSettingsViewController
            vc.setListOfEffects(list: selectedEffects)
        case .days:
            selectedDays[indexPath.row] = !selectedDays[indexPath.row]
            let vc = parent as! AlarmViewController
            vc.setDays(days: selectedDays)
        case .dawn:
                selectedDawn = indexPath.row
            let vc = parent as! AlarmViewController
            vc.setDawn(dawn: selectedDawn ?? 0)
        }

        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backArrowHeight.constant += self.view.safeAreaTop - 20
        headerViewHeight.constant += self.view.safeAreaTop - 20
        tableView.tableFooterView = UIView()
        switch flag{
        case .dawn : mainLabel.text = "Рассвет за"
        case .days : mainLabel.text = "Повтор"
        case .effects : mainLabel.text = "Выбрать эффекты"
        }
       
    }
}
