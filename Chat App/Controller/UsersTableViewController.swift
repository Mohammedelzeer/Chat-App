//
//  UsersTableViewController.swift
//  Chat Clone
//
//  Created by Mohammed on 14/01/2024.
//

import UIKit
//import openssl_grpc

class UsersTableViewController: UITableViewController {
    
    //MARK:- Vars
    
    var allUsers :[User] = []
    var filtredUser: [User] = []
    
    let searchController = UISearchController(searchResultsController: nil)


    override func viewDidLoad() {
        super.viewDidLoad()
        //allUsers = [User.currentUser!]
        
        //createDummuUsers()
        tableView.tableFooterView = UIView()
        downloadUsers()
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Users"
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl

    }
    
    //MARK:- UIScrollView Delegate function
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.refreshControl!.isRefreshing {
            self.downloadUsers()
            self.refreshControl!.endRefreshing()
        }
    }
    

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return searchController.isActive ?filtredUser.count : allUsers.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UsersTableViewCell
        
        let user = searchController.isActive ? filtredUser[indexPath.row] : allUsers[indexPath.row]
        
        cell.configureCell(user: user)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "Color TableView")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = searchController.isActive ? filtredUser[indexPath.row] : allUsers[indexPath.row]
        
        showUserProfile(user)
    }

    
    //MARK:- Download all users from firestore
    
    private func downloadUsers () {
        FUserListener.shared.downloadAllUsersFromFirestore { (firestoreAllUsers) in
            self.allUsers = firestoreAllUsers
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }


}

//MARK:- Extensions

extension UsersTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filtredUser = allUsers.filter({ (user) -> Bool in
            return user.username.lowercased().contains(searchController.searchBar.text!.lowercased())
        })
        tableView.reloadData()
    }
    
    //MARK:- Navigation
    
    private func showUserProfile(_ user: User) {
        
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileView") as! ProfileTableViewController
        
        profileView.user = user
        
        navigationController?.pushViewController(profileView, animated: true)
    }
    
    
}
