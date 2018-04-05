//
//  DetailsViewController.swift
//  RideTest
//
//  Created by dinesh danda on 4/3/18.
//  Copyright © 2018 dinesh danda. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData
class DetailsViewController: UIViewController {
    var dataModel = NSManagedObject()
    @IBOutlet var distanceLbl: UILabel!
    @IBOutlet var calariesLbl: UILabel!
    @IBOutlet var dateLbl: UILabel!
    @IBOutlet var mapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
//         mapView.delegate = self
        self.dateLbl.text = dataModel.value(forKey: "date") as? String
        self.distanceLbl.text = String(format: "%.2f Miles",(dataModel.value(forKey: "distance") as? Double)! )
        
        self.calariesLbl.text = String(format: "%.2f Calaries",(dataModel.value(forKey: "calaries") as? Double)! )
        
        let destLatitude = dataModel.value(forKey: "destinationLat") as? Double
        let destLongitude = dataModel.value(forKey: "destinationLong") as? Double
        
        let sourceLatitude = dataModel.value(forKey: "sourceLat") as? Double
        let sourceLongitude = dataModel.value(forKey: "sourceLong") as? Double
        let camera = GMSCameraPosition.camera(withLatitude: destLatitude!, longitude: destLongitude!, zoom: 18.0)
        mapView.camera = camera
        
        let destiCoords = CLLocationCoordinate2D(latitude: destLatitude!,longitude: destLongitude!)
        let sourceCoords = CLLocationCoordinate2D(latitude: sourceLatitude!,longitude: sourceLongitude!)
        let sourceMarker = GMSMarker(position: sourceCoords)
        sourceMarker.title = "starting point"
        sourceMarker.map = mapView
        let destMarker = GMSMarker(position: destiCoords)
        destMarker.title = "ending point"

        destMarker.map = mapView
        
        
        DispatchQueue.main.async {
          
            let path = GMSPath(fromEncodedPath: (self.dataModel.value(forKey: "polyline") as? String)!)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 20.0
            polyline.strokeColor = UIColor.red
            polyline.map = self.mapView // Your map view
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
