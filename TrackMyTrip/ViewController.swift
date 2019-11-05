//
//  ViewController.swift
//  TrackMyTrip
//
//  Created by 121outsource on 03/11/19.
//  Copyright © 2019 AshishKumar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var tripName: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func startNewtripButton(_ sender: UIButton) {
        let alertController = UIAlertController(title: "New Trip",
                                                        message: "Please enter your trip name",
                                                        preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "TripName"
        })
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alertController.addAction(UIAlertAction(title: "Start", style: .default) { _ in
                    let textField = alertController.textFields![0] as UITextField
                    if textField.text!.isEmpty{
                       return
                    }else{
                        self.tripName = textField.text!
                        self.performSegue(withIdentifier: "HomeToStartSegue", sender: nil)
                    }
                })
                    
                present(alertController, animated: true)
            
    }
    
    @IBAction func showPreviousTripsButton(_ sender: UIButton) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToStartSegue" {
            let view = segue.destination as! NewTripViewController
            view.tripName = tripName
        }
    }
}

