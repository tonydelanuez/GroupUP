//
//  SearchViewController.swift
//  GroupUP
//
//  Created by Eric Goodman on 4/18/17.
//  Copyright © 2017 GroupUP. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var user: FIRUser!
    var groups: [Group] = []
    var filteredGroups: [Group] = []
    var active = false
    private lazy var groupEndpoint: FIRDatabaseReference = FIRDatabase.database().reference().child("pins")
    private lazy var groupsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("members")

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchbar.delegate = self
        self.detectGroups()
        auth()
    }
    
    // Attach a listener to update the view
    private func detectGroups() {
        groupEndpoint.observe(FIRDataEventType.childAdded, with: { snap in
            if let groupInfo = snap.value as? [String:Any] {
                if let id = groupInfo["id"] as? Int, let name = groupInfo["name"] as? String {
                    let stringId = String(id)
                    let group = Group(id: stringId, name: name)
                    self.groups.append(group)
                    self.tableView.reloadData()
                }
            }
        })
        
    }
    
    // TableView overrides
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.active ? self.filteredGroups.count : self.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath)
        if (self.active && self.searchbar.text != "") {
            cell.textLabel?.text = self.filteredGroups[indexPath.item].name
        }
        else {
            cell.textLabel?.text = self.groups[indexPath.item].name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = self.groups[indexPath.item]
        let name = group.name
        let selectAlert = UIAlertController(title: "\(name)", message: "Would you like to enter this group?", preferredStyle: UIAlertControllerStyle.alert)
        
        //If they accept
        selectAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction!) in
            self.groupsRef.child(group.id).setValue([self.user.uid: true])
            self.performSegue(withIdentifier: "presentChatViewController", sender: group)
            
        }))
        selectAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action: UIAlertAction!) in
            print("Chose not to join group")
        }))
        
        present(selectAlert, animated: true, completion:nil)
    }
    
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
    // SearchBar overrides
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.active = false
        self.searchbar.text = ""
        self.searchbar.showsCancelButton = false
        self.searchbar.endEditing(true)
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchbar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.active = true
        self.searchbar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredGroups = self.groups.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
        self.active = self.filteredGroups.count > 0 || self.searchbar.text != ""
        self.tableView.reloadData()
    }
    
    func auth(){
        FIRAuth.auth()!.signIn(withEmail: "ericgoodman@wustl.edu", password: "ericgoodman") { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                print(user!.uid)
                self.user = user
            }
        }
    }
    
}
