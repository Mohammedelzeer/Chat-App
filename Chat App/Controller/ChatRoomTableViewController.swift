//
//  ChatRoomTableViewController.swift
//  Chat Clone
//
//  Created by Mohammed on 15/01/2024.
//

import UIKit

class ChatRoomTableViewController: UITableViewController {
    
    //MARK:- IBActions
    
    @IBAction func conposeBtnTapped(_ sender: UIBarButtonItem) {
        
        let userView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersView") as! UsersTableViewController
        
        navigationController?.pushViewController(userView, animated: true)
    }
    
    
    
    
    //MARK:- Vars
    
    var allChatRooms: [ChatRoom] = []
    var filteredChatRooms: [ChatRoom] = []
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        downloadChatRooms()
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Users"
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl


    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchController.isActive ? filteredChatRooms.count : allChatRooms.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChatTableViewCell
        
        //let chatRoom = ChatRoom(id: "123", chatRoomId: "123", senderId: "123", sendreName: "Moaaz", recieverId: "123", recieverName: "Ali", date: Date(), memberIds: [""], lastMessage: "How are you Ali", unreadCounter: 1, avatarLink: "")
        
        cell.configure(chatRoom: searchController.isActive ? filteredChatRooms[indexPath.row] : allChatRooms[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    //Mark:- TableView Delegation function (Delete)
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let chatRoom = searchController.isActive ? filteredChatRooms[indexPath.row] : allChatRooms[indexPath.row]
            
            FChatRoomListener.shared.deleteChatRoom(chatRoom)
            
            searchController.isActive ? self.filteredChatRooms.remove(at: indexPath.row) : allChatRooms.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chatRoomObject = searchController.isActive ? filteredChatRooms[indexPath.row] : allChatRooms[indexPath.row]
        
        goToMSG(chatRoom: chatRoomObject)
    }
    
    
    
    
    
    
    private func downloadChatRooms() {
        FChatRoomListener.shared.downloadChatRooms { (allFBChatRooms) in
            self.allChatRooms = allFBChatRooms
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    //MARK:- NAvigation
    
    func goToMSG(chatRoom: ChatRoom) {
        
        //TODO:- To make sure that both users have chatrooms
        
        restartChat(chatRoomId: chatRoom.chatRoomId, memberIds: chatRoom.memberIds)
        
        let privateMSGView = MSGViewController(chatId: chatRoom.chatRoomId, recipientId: chatRoom.recieverId, recipientName: chatRoom.recieverName)
        
        navigationController?.pushViewController(privateMSGView, animated: true)
    }

    
}

extension ChatRoomTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredChatRooms = allChatRooms.filter({ (chatRoom) -> Bool in
            return chatRoom.recieverName.lowercased().contains(searchController.searchBar.text!.lowercased())
        })
        tableView.reloadData()
    }
}



