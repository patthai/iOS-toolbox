//
//  ViewController.swift
//  coredata
//
//  Created by pat pataranutaporn on 3/21/19.
//  Copyright © 2019 pat pataranutaporn. All rights reserved.
//
import UIKit
import CoreData


class data_table: UIViewController {
 
    @IBOutlet weak var tableView: UITableView!

    var people: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "The List"
        tableView.register(UITableViewCell.self,forCellReuseIdentifier: "Cell")
         
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Login")
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        self.tableView.reloadData()
    }
    @IBAction func export(_ sender: Any) {
        print(people.count)
        
        for data in people as! [NSManagedObject] {
            var p_email = data.value(forKey: "email") as! String
            var p_password = data.value(forKey: "password") as! String
            print(p_email, p_password)
        }
        
        export_to_csv()
    }
    
    func export_to_csv(){
        var file = "test"
        let fileName = "\(file).csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        var csvText = "username, password\n"
        
        
        if people.count > 0 {
            
            for data in people as! [NSManagedObject] {
                var p_email = data.value(forKey: "email") as! String
                var p_password = data.value(forKey: "password") as! String
                print(p_email, p_password)
                
                let newLine = "\(p_email),\(p_password)\n"
                
                csvText = csvText + newLine
            }
            
            
            
            do {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                
                let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
                vc.excludedActivityTypes = [
                    UIActivity.ActivityType.assignToContact,
                    UIActivity.ActivityType.saveToCameraRoll,
                    UIActivity.ActivityType.postToFlickr,
                    UIActivity.ActivityType.postToVimeo,
                    UIActivity.ActivityType.postToTencentWeibo,
                    UIActivity.ActivityType.postToTwitter,
                    UIActivity.ActivityType.postToFacebook,
                    UIActivity.ActivityType.openInIBooks
                ]
                present(vc, animated: true, completion: nil)
                
            } catch {
                
                print("Failed to create file")
                print("\(error)")
            }
            
        }
    }

    
    
    
}

// MARK: - UITableViewDataSource
extension data_table: UITableViewDataSource {
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        //print (people.count)
        return people.count
    
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            let person = people[indexPath.row]
            let cell =
                tableView.dequeueReusableCell(withIdentifier: "Cell",
                                              for: indexPath)
            cell.textLabel?.text =
                person.value(forKeyPath: "email") as? String
            return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            
            //remove object from core data
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(people[indexPath.row] as NSManagedObject)

            
            //update UI methods
            tableView.beginUpdates()
            people.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            
            appDelegate.saveContext()
        }
    }
    
    
}

