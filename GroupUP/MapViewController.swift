//
//  MapViewController.swift
//  GroupUP
//
//  Created by Justin Guyton on 4/6/17.
//  Copyright © 2017 GroupUP. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    var zoomLatMeters: CLLocationDistance = 2000
    var zoomLongMeters: CLLocationDistance = 2000
    var iLat: CLLocationDegrees = 0
    var iLong: CLLocationDegrees = 0

    @IBOutlet weak var map: MKMapView!
    
    func readJSONObject(object: [String: AnyObject]) {
        guard let markers = object["markers"] as? [[String: AnyObject]] else { return }
        
        for item in markers { //loop through markers and assign variables accordingly
            guard let title = item["title"] as? String,
                let subtitle = item["subtitle"] as? String,
                let lat = item["latitude"] as? CLLocationDegrees,
                let long = item["longitude"] as? CLLocationDegrees else {break}
            
            iLat = lat
            iLong = long
            
            let location = CLLocationCoordinate2DMake(iLat, iLong)
            map.setRegion(MKCoordinateRegionMakeWithDistance(location, zoomLatMeters, zoomLongMeters), animated: true)
            
            let pin = MapMarker(title: title, subtitle: subtitle, coordinate: location)
            map.addAnnotation(pin)
            print(pin.coordinate)
        }
    }
    
    
    //hold press for drop pin
    func action(gestureRecognizer:UIGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: map)
        let newCoordinates = map.convert(touchPoint, toCoordinateFrom: map)
        let pin = MKPointAnnotation()
        pin.coordinate = newCoordinates
        
        print ("Dropped pin - Lat: \(newCoordinates.latitude) Long   \(newCoordinates.longitude)")
        map.addAnnotation(pin)
    }
    
    
    
    /*
     parse the data into an object we can use
     NSJSONSerialization does the parsing and serializing
     */
    func parseJSON() {
        let url = Bundle.main.url(forResource: "DummyMapData", withExtension: "json") //reference JSON file
        let data = NSData(contentsOf: url!)
        
        do {
            let object = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                readJSONObject(object: dictionary)
            }
        } catch {
            // Handle Error
        }
    }
    
    @IBAction func userLocation(_ sender: Any) {
        let userLocation = map.userLocation
        let region = MKCoordinateRegionMakeWithDistance((userLocation.location?.coordinate)!, zoomLatMeters, zoomLongMeters)
        
        iLat = userLocation.coordinate.latitude
        iLong = userLocation.coordinate.longitude
        map.setRegion(region, animated: true)
    }
    
    func zoom() {
        let location = CLLocationCoordinate2DMake(iLat, iLong)
        map.setRegion(MKCoordinateRegionMakeWithDistance(location,zoomLatMeters, zoomLongMeters), animated: true)
    }
    
    @IBAction func zoomOut(_ sender: Any) {
        zoomLatMeters += 1000
        zoomLongMeters += 1000
        zoom()
    }
    
    @IBAction func zoomIn(_ sender: Any) {
        zoomLatMeters -= 1000
        zoomLongMeters -= 1000
        zoom()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        map.showsUserLocation = true
        map.delegate = self
        parseJSON()
        
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.action(gestureRecognizer:)))
        lpgr.minimumPressDuration = 0.5
        map.addGestureRecognizer(lpgr)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
