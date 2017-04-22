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
    private lazy var groupEndpoint: FIRDatabaseReference = FIRDatabase.database().reference().child("pins")
    private lazy var membersEndpoint: FIRDatabaseReference = FIRDatabase.database().reference().child("members")
    private lazy var messagesEndpoint: FIRDatabaseReference = FIRDatabase.database().reference().child("messages")
    
    // Attach a listener to update the view
    private func detectGroups() {
        
        var groupDictionary : Dictionary<String, String> = [:]
        self.groupEndpoint.observe(FIRDataEventType.childAdded,  with: { snap in
            if let groupInfo = snap.value as? [String:Any] {
                if let id = groupInfo["id"] as? Int, let name = groupInfo["name"] as? String {
                    let stringId = String(id)
                    groupDictionary[stringId] = name
                }
                else {
                    print("or here")
                }
            }
            else {
                print("here")
            }
        })
        
        // Listen for the children of "groups" to change
        membersEndpoint.observe(FIRDataEventType.childAdded, with: { snapshot in
            // Get the ID of the group
            let id = snapshot.key
            
            let memberDictionary = snapshot.value as! Dictionary<String, Bool>
            for (name, isValidMember) in memberDictionary {
                if name == self.user.uid && isValidMember {
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
        let group = self.groups[indexPath.item]
        self.performSegue(withIdentifier: "presentChatViewController", sender: group)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // Remove from members
            let id = self.groups[indexPath.item].id
            self.membersEndpoint.child(id).child(self.user.uid).removeValue()
            
            self.groups.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            
            // Ensure that we were not the last person to leave the group
            membersEndpoint.child(id).observeSingleEvent(of: FIRDataEventType.value, with: { snapshot in
                if (snapshot.value as? String) == nil {
                    self.messagesEndpoint.child(id).removeValue()
                    self.groupEndpoint.child(id).removeValue()
                }
            })
        }
    }
    
    // Additional overrides
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let group = sender as? Group else {
            return
        }
        
        if let vc = segue.destination as? ChatViewController {
            vc.group = group
            vc.senderDisplayName = user.email!
            vc.senderId = user.uid
            vc.user = self.user
        }
    }
    
    override func viewDidLoad() {
        FIRAuth.auth()!.signIn(withEmail: "ericgoodman@wustl.edu", password: "ericgoodman") { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                print(user!.uid)
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

