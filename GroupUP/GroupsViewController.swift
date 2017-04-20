//
//  SecondViewController.swift
//  GroupUP
//
//  Created by Tony De La Nuez on 4/5/17.
//  Copyright © 2017 GroupUP. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class GroupsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var groups: [Group] = []
    @IBOutlet weak var tableView: UITableView!
    
    var user: FIRUser!
    private lazy var groupEndpoint: FIRDatabaseReference = FIRDatabase.database().reference().child("groups")
    private lazy var membersEndpoint: FIRDatabaseReference = FIRDatabase.database().reference().child("members")
    
    
    // Attach a listener to update the view
    private func detectGroups() {
        
        var groupDictionary : Dictionary<String, String> = [:]
        self.groupEndpoint.observe(FIRDataEventType.value,  with: { snap in
            groupDictionary = snap.value as! Dictionary<String, String>
        })
        
        // Listen for the children of "groups" to change
        membersEndpoint.observe(FIRDataEventType.childAdded, with: { snapshot in
            // Get the ID of the group
            let id = snapshot.key
            
            let memberDictionary = snapshot.value as! Dictionary<String, Bool>
            for (name, _) in memberDictionary {
                
                if name == self.user.uid {
                    if let groupName = groupDictionary[id] {
                        let group = Group(id: id, name: groupName)
                        self.groups.append(group)
                    }
                }
                
                
            }
            self.tableView.reloadData()
        })
    }
    
    // TableView overrides
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath)
        cell.textLabel?.text = self.groups[indexPath.item].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = self.groups[indexPath.row]
        self.performSegue(withIdentifier: "presentChatViewController", sender: group)
    }
    
    // Additional overrides
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let group = sender as? Group else {
            return
        }
        
        if let vc = segue.destination as? ChatViewController {
            vc.group = group
            vc.senderDisplayName = "Test"
            vc.senderId = "1234"
        }
    }
    
    override func viewDidLoad() {
        FIRAuth.auth()!.signIn(withEmail: "ericgoodman@wustl.edu", password: "ericgoodman") { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                self.user = user
                self.detectGroups()
            }
        }
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

