//
//  MapViewController.swift
//  GroupUP
//
//  Created by Justin Guyton on 4/6/17.
//  Copyright © 2017 GroupUP. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase
import GameplayKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var groupButton: UIButton!
    var touchPoint: CGPoint?
    
    @IBAction func createGroup(_ sender: UIButton) {
       
        let newCoordinates = map.convert(touchPoint!, toCoordinateFrom: map)
        //let pin = MKPointAnnotation()
        //pin.coordinate = newCoordinates
        let theGroupName = groupName.text
        let theGroupDesc = groupDescription.text
        
        let pin = MapMarker(title: theGroupName!, subtitle: theGroupDesc!, coordinate: newCoordinates)
        
        print ("Dropped pin - Lat: \(newCoordinates.latitude) Long   \(newCoordinates.longitude)")
        map.addAnnotation(pin)
        
        //random id
        let random = GKRandomDistribution(lowestValue: 0 , highestValue: 100)
        let r = random.nextInt()
        
        //Add to firebase
        let ref = FIRDatabase.database().reference(withPath: "pins")
        ref.child(String(r)).setValue([
            "description": theGroupDesc!,
            "id": 9,
            "lat": newCoordinates.latitude,
            "long": newCoordinates.longitude,
            "name": theGroupName!
            ])
        
        groupName.isHidden = true
        groupDescription.isHidden = true
        groupButton.isHidden = true
    }
    
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var groupDescription: UITextField!
    
    var zoomLatMeters: CLLocationDistance = 2000
    var zoomLongMeters: CLLocationDistance = 2000
    var iLat: CLLocationDegrees = 0
    var iLong: CLLocationDegrees = 0
    var pinName: String!
    var pinDescription: String!
    var random: Int!

    @IBOutlet weak var map: MKMapView!
    
    func readFromFirebase(){
        let ref = FIRDatabase.database().reference(withPath: "pins")
        ref.observe(.childAdded, with: { snapshot in
            print (snapshot.value!)
            
            if let pin = snapshot.value as? [String:Any] {
                
                if pin["long"] != nil  {
                    print("Pin name: ", pin["name"]!)
                    self.pinName = pin["name"]! as! String
                    
                    print(pin["description"]!)
                    self.pinDescription = pin["description"]! as! String
                    
                    print(pin["lat"]!)
                    self.iLat = pin["lat"]! as! CLLocationDegrees
                    
                    print(pin["long"]!)
                    self.iLong = pin["long"]! as! CLLocationDegrees
                    
                    let location = CLLocationCoordinate2DMake(self.iLat, self.iLong)
                    self.map.setRegion(MKCoordinateRegionMakeWithDistance(location, self.zoomLatMeters, self.zoomLongMeters), animated: true)
                    
                    let pin = MapMarker(title: self.pinName, subtitle: self.pinDescription, coordinate: location)
                    self.map.addAnnotation(pin)
                    print(pin.coordinate)
                }
            }
        })
    }

    //hold press for drop pin
    func action(gestureRecognizer:UIGestureRecognizer){
        touchPoint = gestureRecognizer.location(in: map)
        if(gestureRecognizer.state == UIGestureRecognizerState.ended){
           groupName.isHidden = false
            groupDescription.isHidden = false
            groupButton.isHidden = false
        }
        
    }
    
    /*
     /* 
        Dont need at the moment
     */
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
    */
    
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
        zoomLatMeters += 250
        zoomLongMeters += 250
        zoom()
        print(zoomLatMeters)
        print(zoomLongMeters)
    }
    
    @IBAction func zoomIn(_ sender: Any) {
        if(zoomLatMeters > 250 && zoomLongMeters > 250){
            zoomLatMeters -= 250
            zoomLongMeters -= 250
            zoom()
        }
        print(zoomLatMeters)
        print(zoomLongMeters)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readFromFirebase()
        
        let location = CLLocationCoordinate2DMake(38.902, -90.902)
        map.setRegion(MKCoordinateRegionMakeWithDistance(location, self.zoomLatMeters, self.zoomLongMeters), animated: true)
        // Do any additional setup after loading the view.
        map.showsUserLocation = true
        map.delegate = self
        //parseJSON()
        
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.action(gestureRecognizer:)))
        lpgr.minimumPressDuration = 0.5
        map.addGestureRecognizer(lpgr)
        groupName.isHidden = true
        groupDescription.isHidden = true
        groupButton.isHidden = true

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
