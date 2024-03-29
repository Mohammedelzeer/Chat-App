//
//  ChannelFollowTableViewController.swift
//  Chat Clone
//
//  Created by Mohammed on 05/02/2024.
//

import UIKit

protocol ChannelFollowTableViewControllerDelegate {
    
    func didClickFollow()
}

class ChannelFollowTableViewController: UITableViewController {
    //MARK:- Vars
    
    var channel: Channel!
    var followDelegate : ChannelFollowTableViewControllerDelegate?
    //MARK:- IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var membersLabel: UILabel!
    
    @IBOutlet weak var aboutTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showChannelData()
        configureRightBarButton()
        
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()

    }
    private func showChannelData() {
        self.title = channel.name
        nameLabel.text = channel.name
        membersLabel.text = "\(channel.memberIds.count) Members"
        aboutTextView.text = channel.aboutChannel
        
        if channel.avatarLink != "" {
            FileStorage.downloadImage(imageUrl: channel.avatarLink) { (avatarImage) in
                DispatchQueue.main.async {
                    self.avatarImageView.image = avatarImage != nil ? avatarImage?.circleMasked : UIImage(named: "avatar")
                }
            }
        }else {
            self.avatarImageView.image = UIImage(named: "avatar")
        }
    }
    
    //MARK:-Right button item
    
    private func configureRightBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: .plain, target: self, action: #selector(followChannel))
    }
    
    @objc func followChannel() {
        channel.memberIds.append(User.currentId)
        FChannelListener.shared.saveChannel(channel)
        followDelegate?.didClickFollow()
        self.navigationController?.popViewController(animated: true)
    }


}

