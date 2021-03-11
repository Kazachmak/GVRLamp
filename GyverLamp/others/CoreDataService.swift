//
//  CoreDataService.swift
//  Slwatch
//
//  Created by Максим Казачков on 27.05.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import CoreData
import Foundation
import UIKit
import  Network

class CoreDataService {
    
    /*
    class func listOfLamps() -> [String] {
        var listOfLamps: [String] = []
        if CoreDataService.fetchLamps().count > 0 {
            for element in CoreDataService.fetchLamps() {
                let name = element.value(forKey: "name") as! String
                let ip = element.value(forKey: "ip") as! String
                let port = element.value(forKey: "port") as! String
                let effectsFromLamp = element.value(forKey: "flagEffects") as! Bool
                let flagLampIsControlled = element.value(forKey: "flagLampIsControlled") as! Bool
                listOfLamps.append(ip + ":" + port + ":" + name + ":" + effectsFromLamp.convertToString() + ":" + flagLampIsControlled.convertToString())
            }
        }
        return listOfLamps
    }
 */
    class func fetchLamps() -> [NSManagedObject] {
        var allLamps: [NSManagedObject] = []
       
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return allLamps
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Lamp")
        do {
            allLamps = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return allLamps
    }
/*
    class func setMainLamp(_ ip: String)-> Bool{
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return false
        }

        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Lamp")
        
            fetchRequest.predicate = NSPredicate(format: "ip = %@", "\(ip)")
            let result = try? managedContext.fetch(fetchRequest)
            let resultData = result as! [Lamp]
            for object in resultData {
                if object.ip == ip {
                    object.setValue(true, forKey: "mainLamp")
                }else{
                    object.setValue(false, forKey: "mainLamp")
                }
            }
            do {
                try managedContext.save()
                print("saved!")
                return true
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
                return false
            }
    }
    
    class func fetchLampByIP(_ ip: String)->LampDevice?{
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }

        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Lamp")
        
            fetchRequest.predicate = NSPredicate(format: "ip = %@", "\(ip)")
            let result = try? managedContext.fetch(fetchRequest)
            let resultData = result as! [Lamp]
            for object in resultData {
                if object.ip == ip {
                    let port = object.value(forKey: "port") as! String
                    let name = object.value(forKey: "name") as! String
                    let effectsFromLamp = object.value(forKey: "flagEffects") as! Bool
                    let listOfEffects = object.value(forKey: "listOfEffects") as! String
                    return LampDevice(hostIP: NWEndpoint.Host(ip), hostPort:NWEndpoint.Port(port) ?? 8888, name: name, effectsFromLamp: effectsFromLamp.convertToString(), listOfEffects: listOfEffects.components(separatedBy: ","))
                    
                }
            }
        return nil
    }
    
    class func rename(lamp: LampDevice, newName: String) -> Bool{
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return false
        }

        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Lamp")
        
        let ip = "\(lamp.hostIP)"
            fetchRequest.predicate = NSPredicate(format: "ip = %@", "\(ip)")
            let result = try? managedContext.fetch(fetchRequest)
            let resultData = result as! [Lamp]
            for object in resultData {
                if object.ip == ip {
                    object.setValue("\(newName)", forKey: "name")
                }
            }
            do {
                try managedContext.save()
                print("saved!")
                return true
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
                return false
            }
    }
    */
    
   
    class func deleteAllData(){

    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Lamp")
    fetchRequest.returnsObjectsAsFaults = false

    do {
        let arrUsrObj = try managedContext.fetch(fetchRequest)
        for usrObj in arrUsrObj as! [NSManagedObject] {
            managedContext.delete(usrObj)
        }
       try managedContext.save() //don't forget
        } catch let error as NSError {
        print("delete fail--",error)
      }

    }
    
    class func save()  {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
           return
        }

        let managedContext =
            appDelegate.persistentContainer.viewContext

        for (index,element) in lamps.arrayOfLamps.enumerated(){
            let entity =
                NSEntityDescription.entity(forEntityName: "Lamp",
                                           in: managedContext)!

            let newLamp = NSManagedObject(entity: entity,
                                          insertInto: managedContext)
            if index == lamps.mainLampIndex {
                newLamp.setValue(true, forKeyPath: "mainLamp")
            }else{
                newLamp.setValue(false, forKey:  "mainLamp")
            }
            newLamp.setValue(element.name, forKeyPath: "name")
            newLamp.setValue("\(element.hostIP)", forKey: "ip")
            newLamp.setValue("\(element.hostPort)", forKey: "port")
            newLamp.setValue(element.effectsFromLamp, forKey: "flagEffects")
            newLamp.setValue(element.listOfEffects.joined(separator: ","), forKey: "listOfEffects")
            newLamp.setValue(element.flagLampIsControlled, forKey: "flagLampIsControlled")
            do {
                try managedContext.save()
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                
            }
        }
        
        
    }

    
}
