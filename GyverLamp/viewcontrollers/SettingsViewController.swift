//
//  SettingsViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 18.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import Network
import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //обновлять таблицу или нет
    var updateTableFlag = true
    
    @IBAction func close(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func returnToMainView(_ sender: UIButton) {
        view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }

    var lamp: LampDevice?

    var listOfLamps: [String] = []

    @IBOutlet var heightOfErrorLabel: NSLayoutConstraint!

    @IBOutlet var tableView: UITableView!

    
    // свайп ячеек
    func tableView(_ tableView: UITableView,
                       trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
        {
            updateTableFlag = false
            // добавляем лампу в список
        let AddAction = UIContextualAction(style: .destructive, title:  "Добавить лампу в список", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                print("Update action ...")
                success(true)
                self.updateTableFlag = true
            })
            AddAction.backgroundColor = .gray
            

            return UISwipeActionsConfiguration(actions: [AddAction])
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.set(indexPath.row, forKey: "lampNumber")
        
        if (listOfLamps[indexPath.row].components(separatedBy: ":").count > 3)&&(listOfLamps[indexPath.row].components(separatedBy: ":")[3] == "1"){
            lamp = LampDevice(hostIP: NWEndpoint.Host((listOfLamps[indexPath.row].components(separatedBy: ":"))[0]), hostPort: NWEndpoint.Port((listOfLamps[indexPath.row].components(separatedBy: ":"))[1]) ?? 8888, name: listOfLamps[indexPath.row].components(separatedBy: ":")[2], effectsFromLamp: listOfLamps[indexPath.row].components(separatedBy: ":")[3], listOfEffects: (listOfLamps[indexPath.row].components(separatedBy: ":")[4]).components(separatedBy: ","))
        }else{
            if listOfLamps[indexPath.row].components(separatedBy: ":").count > 2{
            lamp = LampDevice(hostIP: NWEndpoint.Host((listOfLamps[indexPath.row].components(separatedBy: ":"))[0]), hostPort: NWEndpoint.Port((listOfLamps[indexPath.row].components(separatedBy: ":"))[1]) ?? 8888, name: listOfLamps[indexPath.row].components(separatedBy: ":")[2], effectsFromLamp: listOfLamps[indexPath.row].components(separatedBy: ":")[3])
            }
        }
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [self] _ in
            
            if lamp?.connectionStatus == true {
                self.dismiss(animated: true)
            } else {
                UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.heightOfErrorLabel.constant = 24
                })
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfLamps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "lampCell", for: indexPath) as! LampsTableViewCell

        if listOfLamps[indexPath.row].components(separatedBy: ":").count > 2 {
        cell.lampLabel.text = listOfLamps[indexPath.row].components(separatedBy: ":")[2]
        }
        
        if let currentLamp = lamp {
            if cell.lampLabel.text == "\(currentLamp.name)" {
                cell.lampLabel.textColor = redColor // текущая лампа подсвечена красным
                cell.settingsButtonOut.alpha = 1.0
             //  cell.settingsButtonOut.isUserInteractionEnabled = true
            } else {
                cell.lampLabel.textColor = blackColor
                cell.settingsButtonOut.alpha = 0.3
               // cell.settingsButtonOut.isUserInteractionEnabled = false
            }
        }
        

        return cell
    }

    @IBAction func settingsButton(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }

        UserDefaults.standard.set(indexPath.row, forKey: "lampNumber")
        
        if (listOfLamps[indexPath.row].components(separatedBy: ":")[3] == "1")&&(listOfLamps[indexPath.row].components(separatedBy: ":").count > 3){
            lamp = LampDevice(hostIP: NWEndpoint.Host((listOfLamps[indexPath.row].components(separatedBy: ":"))[0]), hostPort: NWEndpoint.Port((listOfLamps[indexPath.row].components(separatedBy: ":"))[1]) ?? 8888, name: listOfLamps[indexPath.row].components(separatedBy: ":")[2], effectsFromLamp: listOfLamps[indexPath.row].components(separatedBy: ":")[3], listOfEffects: (listOfLamps[indexPath.row].components(separatedBy: ":")[4]).components(separatedBy: ","))
        }else{
            if listOfLamps[indexPath.row].components(separatedBy: ":").count > 2{
            lamp = LampDevice(hostIP: NWEndpoint.Host((listOfLamps[indexPath.row].components(separatedBy: ":"))[0]), hostPort: NWEndpoint.Port((listOfLamps[indexPath.row].components(separatedBy: ":"))[1]) ?? 8888, name: listOfLamps[indexPath.row].components(separatedBy: ":")[2], effectsFromLamp: listOfLamps[indexPath.row].components(separatedBy: ":")[3])
            }
        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "lampsettings") as! LampSettingsViewController
        vc.lamp = lamp
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }

    @IBOutlet var addButtonOut: UIButton!

    // обновляем таблицу
    @objc func updateTable() {
        if let listOfLampTemp = UserDefaults.standard.array(forKey: "listOfLamps") {
            listOfLamps = listOfLampTemp as! [String]
        }
        if updateTableFlag{
            tableView.reloadData()
        }
    }

    @IBOutlet var scanOut: UIButton!

    @IBOutlet var backArrowHeight: NSLayoutConstraint!

    @IBOutlet var headerViewHeight: NSLayoutConstraint!

    override func viewWillAppear(_ animated: Bool) {
        // читаем из памяти список сохранненых ламп
        if let listOfLampTemp = UserDefaults.standard.array(forKey: "listOfLamps") {
            listOfLamps = listOfLampTemp as! [String]
        }
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        heightOfErrorLabel.constant = 0
        backArrowHeight.constant += view.safeAreaTop - 20
        headerViewHeight.constant += view.safeAreaTop - 20
        NotificationCenter.default.addObserver(self, selector: #selector(updateTable), name: Notification.Name("updateInterface"), object: nil)
        tableView.separatorStyle = .none
        scanOut.imageView?.contentMode = .scaleAspectFit
        addButtonOut.imageView?.contentMode = .scaleAspectFit
    }
}
