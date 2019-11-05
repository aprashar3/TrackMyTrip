//
//  PreviousTripViewController.swift
//  TrackMyTrip
//
//  Created by 121outsource on 03/11/19.
//  Copyright © 2019 AshishKumar. All rights reserved.
//

import UIKit
import CoreData

class PreviousTripViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tripData: [NSManagedObject] = []
    var selectedTrip: Trip?
    
    @IBOutlet weak var tripListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
          NSFetchRequest<NSManagedObject>(entityName: "Trip")
        
        //3
        do {
          tripData = try managedContext.fetch(fetchRequest)
            for trip in tripData{
                print(trip.value(forKey: "name") as! String)
                let location = trip.value(forKey: "locations") as! NSSet
                let locationarray = location.allObjects as! [Location]
            }
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    
    }
    
// MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "PreviousToStartSegue"{
               let view = segue.destination as! NewTripViewController
               view.isFromList = true
               view.trip = selectedTrip
           }
       }
    
//MARK: Table view Datasource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tripData[indexPath.row].value(forKey: "name") as? String
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTrip = tripData[indexPath.row] as? Trip
        performSegue(withIdentifier: "PreviousToStartSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.contentSize.height
    }
}
