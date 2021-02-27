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
    
    class func listOfLamps() -> [String] {
        var listOfLamps: [String] = []
        if CoreDataService.fetchLamps().count > 0 {
            for element in CoreDataService.fetchLamps() {
                let name = element.value(forKey: "name") as! String
                let ip = element.value(forKey: "ip") as! String
                let port = element.value(forKey: "port") as! String
                let effectsFromLamp = element.value(forKey: "flagEffects") as! Bool
                
                listOfLamps.append(ip + ":" + port + ":" + name + ":" + effectsFromLamp.convertToString())
            }
        }
        return listOfLamps
    }

    class func fetchLamps() -> [NSManagedObject] {
        var tasks: [NSManagedObject] = []
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return tasks
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Lamp")
        do {
            tasks = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return tasks
    }

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
    
    class func checkIP(_ ip: String)-> Bool{
        var arrayIP: [String] = []
        
        for element in CoreDataService.fetchLamps(){
            arrayIP.append(element.value(forKey: "ip") as! String)
        }
        
        return arrayIP.contains(ip)
    }
    
    class func save(lamp: LampDevice) -> Bool {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return false
        }

        let managedContext =
            appDelegate.persistentContainer.viewContext

        let entity =
            NSEntityDescription.entity(forEntityName: "Lamp",
                                       in: managedContext)!

        let newLamp = NSManagedObject(entity: entity,
                                      insertInto: managedContext)

        newLamp.setValue(lamp.name, forKeyPath: "name")
        newLamp.setValue("\(lamp.hostIP)", forKey: "ip")
        newLamp.setValue("\(lamp.hostPort)", forKey: "port")
        newLamp.setValue(lamp.effectsFromLamp, forKey: "flagEffects")
        newLamp.setValue(lamp.listOfEffects.joined(separator: ","), forKey: "listOfEffects")
        newLamp.setValue(lamp.mainLamp, forKey: "mainLamp")
        do {
            try managedContext.save()
            return true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
    }

    class func delete(ip: String) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let fetchRequest: NSFetchRequest<Lamp> = Lamp.fetchRequest()
        let context = appDelegate.persistentContainer.viewContext
        fetchRequest.predicate = NSPredicate(format: "ip = %@", "\(ip)")

        do {
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                context.delete(object)
            }
            try context.save()
        } catch _ {
            print(Error.self)
        }
    }
}
