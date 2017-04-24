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
import FirebaseAuth
import GameplayKit

class MapViewController: UIViewController, MKMapViewDelegate {
    var user:FIRUser!
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var instrLabel: UILabel!
    private lazy var groupsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("members")
    


    @IBOutlet weak var groupDescHeader: UILabel!
    @IBOutlet weak var pinInfoStack: UIStackView!
    @IBOutlet weak var pinGroupDescription: UILabel!
    @IBOutlet weak var joinGroup: UIButton!
    @IBOutlet weak var cancelGroupJoin: UIButton!
    
    
    var touchPoint: CGPoint?
    var clickedPinTitle: String!
    
    @IBAction func cancelGroup(_ sender: UIButton) {
        hideAll()
        clearBoxes()
    }
    
    //This function available only after long press on the map. 
    //Just allows for submission of new group based on the text fields that pop up. 
    @IBAction func createGroup(_ sender: UIButton) {
        let newCoordinates = map.convert(touchPoint!, toCoordinateFrom: map)
        //let pin = MKPointAnnotation()
        //pin.coordinate = newCoordinates
        let theGroupName = groupName.text
        let theGroupDesc = groupDescription.text
        
        
        //Add to firebase
        let ref = FIRDatabase.database().reference(withPath: "pins")
        //Check for both entries
        
            if(theGroupName != "" && theGroupDesc != ""){
                let pin = MapMarker(title: theGroupName!, subtitle: theGroupDesc!, coordinate: newCoordinates)
                
                print ("Dropped pin - Lat: \(newCoordinates.latitude) Long   \(newCoordinates.longitude)")
                map.addAnnotation(pin)
                
                //random id generated for pin
                let random = GKRandomDistribution(lowestValue: 0 , highestValue: 10000)
                let r = random.nextInt()

                ref.child(String(r)).setValue([
                    "description": theGroupDesc!,
                    "id": r,
                    "lat": newCoordinates.latitude,
                    "long": newCoordinates.longitude,
                    "name": theGroupName!
                    ])
                //Alert upon success
                let alertController = UIAlertController(title: "Group successfully created!", message:
                    "Name of group: \(theGroupName!) \n Description: \(theGroupDesc!)", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
                 //////---------------------------------------------
                ////ISSUE HERE WITH ADDING TO GROUP BECAUSE WE DONT HAVE THE USER
                self.groupsRef.child(String(r)).setValue([self.user.uid: true])
                //////---------------------------------------------
                
                hideAll()
                clearBoxes()
            } else {
                //Not all text boxes filled, do not place marker and alert failure.
                let alertController = UIAlertController(title: "Submission Unsuccessful", message:
                    "Please complete all fields.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var groupDescription: UITextField!
    
    var zoomLatMeters: CLLocationDistance = 2000
    var zoomLongMeters: CLLocationDistance = 2000
    var iLat: CLLocationDegrees = 0
    var iLong: CLLocationDegrees = 0
    var pinName: String!
    var pinID: Int!
    var pinDescription: String!
    var random: Int!

    @IBOutlet weak var map: MKMapView!
    
    //Hide the text boxes, buttons
    func hideAll(){
        groupName.isHidden = true
        groupDescription.isHidden = true
        groupButton.isHidden = true
        cancelButton.isHidden = true
        pinInfoStack.isHidden = true
    }
    
    //Show all the text boxes and buttons
    func showAll(){
        groupName.isHidden = false
        groupDescription.isHidden = false
        groupButton.isHidden = false
        cancelButton.isHidden = false
    }
    
    func showPinInfo(){
          pinInfoStack.isHidden = false

    }
    
    //Clear the text boxes
    func clearBoxes(){
        groupName.text = ""
        groupDescription.text = ""
    }
    
    
    //Read from firebase graps all the points in the "pins" section of the Firebase database. 
    //Each pin is added onto the map with its given properties: ID, Description, Lat, and Long.
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
           showAll()
        }
        
    }
    
    //check to see if marker was clicked
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            pinGroupDescription.text = annotation.subtitle!!
            showPinInfo()
            clickedPinTitle = annotation.title!!
            print("Title: \(annotation.title!!)");
        }
    }

    //If the user clicks the "Me" button they're sent to their GPS location. Unfortunately, the simulator uses Cupertino which isn't very nice.
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
    
    //ZoomIn/ZoomOut are for simulator testing
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
    
    
    @IBAction func joinGroup(_ sender: Any) {
        //loop through firebase for group title and gets id
        let ref = FIRDatabase.database().reference(withPath: "pins")
        ref.observe(.childAdded, with: { snapshot in
            if let pin = snapshot.value as? [String:Any] {
                if pin["name"]! as! String == self.clickedPinTitle  {
                    self.pinID = pin["id"]! as! Int
                    self.groupsRef.child(String(self.pinID)).setValue([self.user.uid: true])
                }
                else {
                    print("Searching...", pin["name"]! as! String)
                }
            }
        })
        hideAll()
        
        let alertController = UIAlertController(title: clickedPinTitle, message: "Group joined!", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
        //segue unwind
//        self.performSegue(withIdentifier: "unwindToGroups", sender: self)
    }

    func auth(){
        user = FIRAuth.auth()?.currentUser
        if let user = user {
            let uid = user.uid
            let email = user.email
            print(uid)
            print(String(describing: email))
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        auth()

        //set the initial location on MapView to WashU
        let location = CLLocationCoordinate2DMake(38.902, -90.902)
        map.setRegion(MKCoordinateRegionMakeWithDistance(location, self.zoomLatMeters, self.zoomLongMeters), animated: true)
        // Do any additional setup after loading the view.
        map.showsUserLocation = true
        map.delegate = self
        hideAll()
        //Stylize buttons
        groupButton.layer.cornerRadius = 10
        cancelButton.layer.cornerRadius = 10
        
        joinGroup.layer.cornerRadius = 10
        cancelGroupJoin.layer.cornerRadius = 10
        pinGroupDescription.layer.cornerRadius = 10
        groupDescHeader.layer.cornerRadius = 10
        //Configure long press gesture
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.action(gestureRecognizer:)))
        lpgr.minimumPressDuration = 0.5
        map.addGestureRecognizer(lpgr)


    }
    
    override func viewDidAppear(_ animated: Bool) {
        readFromFirebase()
        //Hide all UI Elements that have to deal with adding a new group
        fadeLabel(view: self.view, delay: 0.5)
    }
    func fadeLabel(view: UIView, delay: TimeInterval){
        
        let durationLast = 10.5
        let durationFade = 5.0
        UIView.animate(withDuration: durationLast, animations:{() -> Void in
            self.instrLabel.alpha = 1
        }) {(Bool) -> Void in
            
                UIView.animate(withDuration: durationFade, delay: delay, animations: {() ->
                    Void in self.instrLabel.alpha = 0
            }, completion: nil)
        }
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
