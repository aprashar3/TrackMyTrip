//
//  NewTripViewController.swift
//  TrackMyTrip
//
//  Created by 121outsource on 03/11/19.
//  Copyright © 2019 AshishKumar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class NewTripViewController: UIViewController {
    
    let myLoacationManager = CLLocationManager()
    var trip: Trip?
    private var locationList: [CLLocation] = []
    private var newLocation : CLLocation?
    private var speed: CLLocationSpeed = CLLocationSpeed()
    var isFromList : Bool = false
    var tripName:String?
    private var tripId : Int?
    
    @IBOutlet weak var colorInfoView: UIView!
    @IBOutlet weak var currentTripMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentTripMapView.delegate = self
        if !isFromList{
            self.colorInfoView.isHidden = true
            myLoacationManager.requestAlwaysAuthorization()
            myLoacationManager.requestWhenInUseAuthorization()
            if CLLocationManager.locationServicesEnabled() {
                myLoacationManager.delegate = self
                myLoacationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                myLoacationManager.startUpdatingLocation()
            }
            currentTripMapView.showsUserLocation = true
        }else{
           loadTripMap()
        }
        
        currentTripMapView.delegate = self
        
        
        tripId = UserDefaults.standard.integer(forKey: "tripId")
        if tripId == nil{
            tripId = 1
            UserDefaults.standard.set(tripId, forKey: "tripId")
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)

      myLoacationManager.stopUpdatingLocation()
    }

  
    @IBAction func doneBarButton(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "End trip?",
                                                message: "Do you wish to end your trip?",
                                                preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            self.myLoacationManager.stopUpdatingLocation()
          self.stopTrip()
            self.loadTripMap()
        })
        alertController.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
          _ = self.navigationController?.popToRootViewController(animated: true)
        })
            
        present(alertController, animated: true)
    }
    
}

extension NewTripViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        if let location = locations.last{
            newLocation = location
            self.saveLocationData()
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.currentTripMapView.setRegion(region, animated: true)
        }

    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = MKMarkerAnnotationView()
        guard let annotation = annotation as? SpeedAnnotation else {return nil}
        var identifier = ""
        var color = UIColor.red
        switch annotation.type {
        case .twenty:
            identifier = "twenty"
            color = .systemIndigo
        case .thirty:
            identifier = "thirty"
            color = .systemBlue
        case .fifty:
            identifier = "fifty"
            color = .systemGreen
        case .eighty:
            identifier = "eighty"
            color = .systemYellow
        case .hundred:
            identifier = "hundred"
            color = .systemOrange
        case .onetwenty:
            identifier = "onetwenty"
            color = .systemRed
        case .onefifty:
            identifier = "onefifty"
            color = .lightGray
        case .twohundred:
            identifier = "twohundred"
            color = .darkGray
        case .extra:
            identifier = "extra"
            color = .black
        default:
            identifier = "extra"
            color = .black
        }
        if let dequedView = mapView.dequeueReusableAnnotationView(
                withIdentifier: identifier)
                as? MKMarkerAnnotationView {
                annotationView = dequedView
            } else{
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            annotationView.markerTintColor = color
            annotationView.clusteringIdentifier = identifier
            return annotationView
        
    }
   func saveLocationData() {
        let lastLocation = locationList.last
        speed = newLocation!.speed
        let speedkmph = speed * 3.6
    if lastLocation == nil{
        locationList.append(newLocation!)
       
    }else{
        if speedkmph > 0.00 && speedkmph < 20.00{
            self.checkInterval(allowedTimeInterval: 60.00)
            
        }else if speedkmph > 20.00 && speedkmph < 30.00{
              self.checkInterval(allowedTimeInterval: 50.00)
            
        }else if speedkmph > 30.00 && speedkmph < 50.00{
              self.checkInterval(allowedTimeInterval: 40.00)

        }else if speedkmph > 50.00 && speedkmph < 80.00{
               self.checkInterval(allowedTimeInterval: 30.00)

        }else if speedkmph > 80.00 && speedkmph < 100.00{
                self.checkInterval(allowedTimeInterval: 20.00)

        }else if speedkmph > 100.00 && speedkmph < 120.00{
                self.checkInterval(allowedTimeInterval: 10.00)

        }else if speedkmph > 120.00 && speedkmph < 150.00{
                self.checkInterval(allowedTimeInterval: 5.00)

        }else if speedkmph > 150.00 && speedkmph < 200.00{
                self.checkInterval(allowedTimeInterval: 2.00)

        }else{
            locationList.append(newLocation!)
        }
    }
        
    
    }
    func checkInterval(allowedTimeInterval : Double){
        let interval = newLocation!.timestamp.timeIntervalSince(locationList.last!.timestamp)
        if interval >= allowedTimeInterval {
            print(interval)
            locationList.append(newLocation!)
        }
    }
    func stopTrip() {
        let newTrip = Trip(context: CoreDataStack.context)
        newTrip.name = tripName
        newTrip.timestamp = Date()
        newTrip.id = Int16(tripId!)
        
        for location in locationList {
          let locationObject = Location(context: CoreDataStack.context)
          locationObject.timestamp = location.timestamp
          locationObject.latitude = location.coordinate.latitude
          locationObject.longitude = location.coordinate.longitude
            locationObject.speed = location.speed * 3.6
          newTrip.addToLocations(locationObject)
        }
        
        CoreDataStack.saveContext()
        
        trip = newTrip
        
    }
    
    
}

extension NewTripViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
          return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 3
        return renderer
      }

    func setColor(speedkmph: Double) -> ColorType {
        if speedkmph > 0.00 && speedkmph < 20.00{
            return .twenty
            
        }else if speedkmph > 20.00 && speedkmph < 30.00{
              
            return .thirty
            
        }else if speedkmph > 30.00 && speedkmph < 50.00{
              
            return .fifty

        }else if speedkmph > 50.00 && speedkmph < 80.00{
               
            return .eighty

        }else if speedkmph > 80.00 && speedkmph < 100.00{
            return .hundred
            

        }else if speedkmph > 100.00 && speedkmph < 120.00{
            return .onetwenty

        }else if speedkmph > 120.00 && speedkmph < 150.00{
            return .onefifty

        }else if speedkmph > 150.00 && speedkmph < 200.00{
            return .twohundred

        }else{
            return .extra
        }
    }
    
    func loadTripMap() {
        self.currentTripMapView.showsUserLocation = false
        self.colorInfoView.isHidden = false
        self.myLoacationManager.stopUpdatingLocation()
        self.navigationItem.rightBarButtonItem = nil;
        
          guard
            let locations = trip!.locations,
          locations.count > 0
        else {
          return
        }
          
        let latitudes = locations.map { location -> Double in
          let location = location as! Location
          return location.latitude
        }
          
        let longitudes = locations.map { location -> Double in
          let location = location as! Location
          return location.longitude
        }
        
        
        let maxLat = latitudes.max()!
        let minLat = latitudes.min()!
        let maxLong = longitudes.max()!
        let minLong = longitudes.min()!
          
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLong + maxLong) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3,
                                    longitudeDelta: (maxLong - minLong) * 1.3)
        currentTripMapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
        
        
            let locationArray = locations.allObjects as! [Location]
            for eachLocation in locationArray{
                let speedKmph = eachLocation.speed
                let intSpeed = Int(speedKmph)
                let annotation = SpeedAnnotation(coordinate: CLLocationCoordinate2D(latitude: eachLocation.latitude, longitude: eachLocation.longitude), title: "\(intSpeed)Kmph", type: setColor(speedkmph: speedKmph))
                currentTripMapView.addAnnotation(annotation)
            }
            
        
    }
}
