//
//  SecondViewController.swift
//  GroupUP
//
//  Created by Tony De La Nuez on 4/5/17.
//  Copyright © 2017 GroupUP. All rights reserved.
//

import UIKit
import FirebaseDatabase


class SecondViewController: UITableViewController {
    
    private var groups: [Group] = []
    private var groupEndpoint: FIRDatabaseReference = FIRDatabase.database().reference(withPath: "groups")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TableView overrides
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath)
        cell.textLabel?.text = self.groups[indexPath.item].name
        return cell
    }
    
    // Attach a listener to update the view
    private func detectChannels() {
        // Listen for the children of "groups" to change
        groupEndpoint.observe(FIRDataEventType.childAdded, with: { snapshot in
            // Get the ID of the group
            let id = snapshot.key
            
            // Conveniently store data
            guard let data = snapshot.value as? Dictionary<String, AnyObject> else {
                return
            }
            
            // Append new group and reload tableView
            if let name = data["name"] as? String {
                let group = Group(id: id, name: name)
                self.groups.append(group)
                self.tableView.reloadData()
            }
            
        })
    }
    
    
}

