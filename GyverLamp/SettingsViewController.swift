//
//  SettingsViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 18.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit
import Network

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfLamps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "lampCell", for: indexPath) as! LampsTableViewCell
        cell.lampLabel.text = listOfLamps[indexPath.row]
        return cell
    }
    

    
    @IBAction func addButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Добавьте лампу", message: "Введите адрес и порт", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Введите IP-адрес"
            }

            alert.addTextField { (textField) in
                textField.placeholder = "Введите порт"
            }

            alert.addAction(UIAlertAction(title: "Добавить", style: .default, handler: { [weak alert] (_) in
                if let textField = alert?.textFields?[0], let hostIP = textField.text {
                    if let textField = alert?.textFields?[1], let hostPort = textField.text {
                        if hostIP.isValidIP()&&hostPort.isValidPort(){
                            let lamp = LampDevice(hostIP:NWEndpoint.Host(hostIP), hostPort: NWEndpoint.Port (hostPort) ?? 8888)
                            lamp.updateStatus(lamp: lamp)
                        }
                    }
                }

                
            }))
            alert.addAction(UIAlertAction(title: "Отменить", style: .default, handler: { [weak alert] (_) in
                           
            }))

            self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBOutlet weak var addButtonOut: UIButton!
    
    @IBAction func closeButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var closeButtonOut: UIButton!
    
    
    @IBAction func removeButton(_ sender: UIButton) {
    }
    
    @IBOutlet weak var removeButtonOut: UIButton!
    
    @objc func updateInterface(){
        tableView.reloadData()
        
    }
    
    @IBAction func scan(_ sender: UIButton) {
        
       
                //LampDevice.scan()
        
       
        
    }
    
    @IBOutlet weak var scanOut: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButtonOut.addBoxShadow()
        removeButtonOut.addBoxShadow()
        addButtonOut.addBoxShadow()
        scanOut.addBoxShadow()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateInterface), name: Notification.Name("updateInterface"), object: nil)
    }
    

   

}
