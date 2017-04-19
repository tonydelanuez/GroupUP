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

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var groups: [Group] = []
    var filteredGroups: [Group] = []
    var active = false
    private lazy var groupEndpoint: FIRDatabaseReference = FIRDatabase.database().reference().child("groups")
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
  
    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchbar.delegate = self
        self.detectGroups()
    }
    
    // Attach a listener to update the view
    private func detectGroups() {
        // Listen for the children of "groups" to change
        groupEndpoint.observe(FIRDataEventType.childAdded, with: { snapshot in
            // Get the ID of the group
            let id = snapshot.key
            
            // Conveniently store data
            guard let name = snapshot.value as? String else {
                return
            }
            
            let group = Group(id: id, name: name)
            self.groups.append(group)
            if !self.active {
                self.tableView.reloadData()
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

    
    
}
