//
//  MapViewController.swift
//  GroupUP
//
//  Created by Justin Guyton on 4/6/17.
//  Copyright © 2017 GroupUP. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    func readJSONObject(object: [String: AnyObject]) {
        guard let markers = object["markers"] as? [[String: AnyObject]] else { return }
        
        for item in markers { //loop through markers and assign variables accordingly
            guard let title = item["title"] as? String,
                let subtitle = item["subtitle"] as? String,
                let lat = item["latitude"] as? CLLocationDegrees,
                let long = item["longitude"] as? CLLocationDegrees else {break}
            
            let location = CLLocationCoordinate2DMake(lat, long)
            map.setRegion(MKCoordinateRegionMakeWithDistance(location, 1500, 1500), animated: true)
            
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        parseJSON()
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
