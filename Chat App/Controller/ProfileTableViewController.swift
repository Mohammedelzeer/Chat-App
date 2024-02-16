//
//  ProfileTableViewController.swift
//  Chat Clone
//
//  Created by Mohammed on 14/01/2024.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    var user: User?
    
    //MARK:- IB Outlet
    
    @IBOutlet weak var avatarImageViewOutlet: UIImageView!
    @IBOutlet weak var usernameLabelOutlet: UILabel!
    @IBOutlet weak var statusLabelOutlet: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        setupUI()
        

    }
    
    private func setupUI() {
        if user != nil {
            self.title = user!.username
            
            usernameLabelOutlet.text = user?.username
            statusLabelOutlet.text = user?.status
            
            if user!.avatarLink != "" {
                FileStorage.downloadImage(imageUrl: user!.avatarLink) { (avatarImage) in
                    self.avatarImageViewOutlet.image = avatarImage?.circleMasked
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 5.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "Color TableView")
        return headerView
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            print("Start Chat")
            
            let chatId = startChat(sendre: User.currentUser!, reciver: user!)
            
            let privateMSGView = MSGViewController(chatId: chatId, recipientId: user!.id, recipientName: user!.username)
            
            navigationController?.pushViewController(privateMSGView, animated: true)
        }
    }



}
