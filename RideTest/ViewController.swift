//
//  ViewController.swift
//  RideTest
//
//  Created by dinesh danda on 4/3/18.
//  Copyright © 2018 dinesh danda. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData
class ViewController: UIViewController , CLLocationManagerDelegate , GMSMapViewDelegate {
    @IBOutlet var mapView: GMSMapView!
    var myRides  = [NSManagedObject] ()
    var firstTimeLocationTaken : Bool = false
    let locationManager = CLLocationManager()
    var polyLinesArr = [GMSPolyline]()
    var sourceCoordinates = CLLocationCoordinate2D()
    var destinationCoordinates = CLLocationCoordinate2D()
    var previousLocation = CLLocation()
    var sourceLocation = CLLocation()
    var destinationLocation = CLLocation()
    var polyLineString = String()
    @IBOutlet var startRideBtn: UIButton!
    
    // MARK: LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()
        startRideBtn.isHidden = true
        startRideBtn.tag = 0
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    // MARK: CLLocation Delegate Methods
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location = locations.last
        
        if !firstTimeLocationTaken {
            firstTimeLocationTaken = true
            sourceCoordinates = (location?.coordinate)!
            sourceLocation = location!
            previousLocation = location!
            let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 14.0)
            mapView.camera = camera
        }
        if startRideBtn.tag == 1{
            destinationLocation = location!
            if previousLocation.distance(from: location!) > 2 {
                previousLocation = location!
                DispatchQueue.main.async {
                    self.getPolylineRoute(from: self.sourceCoordinates, to: (location?.coordinate)!)
                }

            }
        }
        
        
        
    }
    // MARK: MapView Delegate Methods

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D){
        
        if startRideBtn.tag == 0 {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
        destinationCoordinates = coordinate
        mapView.clear() // clearing Pin before adding new
        let marker = GMSMarker(position: coordinate)
        marker.map = mapView
        startRideBtn.isHidden = false
        }
    }
    
    // MARK: Drawing path  Methods

    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=true&mode=driving&key=AIzaSyAOORbM7BE-AC9XpIz697-K2s6tmgQ2yng")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        guard let routes = json["routes"] as? NSArray else {
                            
                            return
                        }
                        
                        if (routes.count > 0) {
                            DispatchQueue.main.async {
                                
                                let overview_polyline = routes[0] as? NSDictionary
                                let dictPolyline = overview_polyline?["overview_polyline"] as? NSDictionary
                                
                                let points = dictPolyline?.object(forKey: "points") as? String
                                
                                self.showPath(polyStr: points!)
                            }
                        }
                        else {
                            //
                        }
                    }
                }
                catch {
                    print("error in JSONSerialization")
                    DispatchQueue.main.async {
                        //self.activityIndicator.stopAnimating()
                    }
                }
            }
        })
        task.resume()
    }
    
    func showPath(polyStr :String){
        DispatchQueue.main.async {
            for pline in self.polyLinesArr
            {
                pline.map = nil
            }
            let path = GMSPath(fromEncodedPath: polyStr)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 5.0
            polyline.strokeColor = UIColor.red
            self.polyLinesArr.append(polyline)
            self.polyLineString = polyStr
            polyline.map = self.mapView // Your map view
        }
    }
    func getDistance(source : CLLocation , destination : CLLocation) -> Double {
        return destination.distance(from: source)/1609.344
    }
    // MARK: Saving Data into CoreData

    func save(date: String , distance: Double , pline: String , calaries: Double) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "MyRides",
                                       in: managedContext)!
        
        let ride = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3
        ride.setValue(date, forKeyPath: "date")
        ride.setValue(distance, forKeyPath: "distance")
        ride.setValue(pline, forKeyPath: "polyline")
        ride.setValue(calaries, forKeyPath: "calaries")
        ride.setValue(self.destinationLocation.coordinate.latitude, forKeyPath: "destinationLat")
        ride.setValue(self.destinationLocation.coordinate.longitude, forKeyPath: "destinationLong")
        
        ride.setValue(self.sourceLocation.coordinate.latitude, forKeyPath: "sourceLat")
        ride.setValue(self.sourceLocation.coordinate.longitude, forKeyPath: "sourceLong")


        // 4
        do {
            try managedContext.save()
            self.mapView.clear()

        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: Button Actions

    @IBAction func didTappedStartRideButton(_ sender: UIButton) {
        
        if sender.tag == 0 {
            startRideBtn.setTitle("Stop Ride", for: .normal)
            sender.tag = 1
            }
        else{
            self.startRideBtn.isHidden = true
            sender.tag = 0
            startRideBtn.setTitle("Start Ride", for: .normal)
            let alertController: UIAlertController = UIAlertController(title: "", message: "Do you wnat to save this ride?", preferredStyle: .alert)
            let noAction: UIAlertAction = UIAlertAction(title: "NO", style: .default) { action -> Void in
                
                self.mapView.clear()
            }
            let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
                
                let endDate = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
                
                let dateResult = formatter.string(from: endDate)
                let distanceInMiles = self.getDistance(source: self.sourceLocation, destination: self.destinationLocation)
                self.save(date: dateResult, distance: distanceInMiles, pline: self.polyLineString ,calaries: SingltonClass.sharedManager.getCalariesExertes(distance: distanceInMiles))
            }
            alertController.addAction(noAction)
            alertController.addAction(yesAction)

            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func didTappedShowHistory(_ sender: UIBarButtonItem) {
        
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "MyRides")
        
        //3
        do {
            myRides = try managedContext.fetch(fetchRequest)
            
            if myRides.count>0 {
                let rvc = self.storyboard?.instantiateViewController(withIdentifier: "RideDetailsViewController") as! RideDetailsViewController
                rvc.ridesArr = myRides
                self.navigationController?.pushViewController(rvc, animated: true)
            }
            else{
                let alertController: UIAlertController = UIAlertController(title: "", message: "You dont have saved paths", preferredStyle: .alert)
                let noAction: UIAlertAction = UIAlertAction(title: "NO", style: .default) { action -> Void in
                    
                   // self.mapView.clear()
                }
                alertController.addAction(noAction)
                self.present(alertController, animated: true, completion: nil)

            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

