//
//  UsersTableViewCell.swift
//  Chat Clone
//
//  Created by Mohammed on 14/01/2024.
//

import UIKit

class UsersTableViewCell: UITableViewCell {
    
    //MARK:- IB Outlets
    
    @IBOutlet weak var avatarInageViewOutlet: UIImageView!
    
    @IBOutlet weak var usernameLableOutlet: UILabel!
    
    @IBOutlet weak var statusLableOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(user: User) {
        
        usernameLableOutlet.text = user.username
        statusLableOutlet.text = user.status
        
        if user.avatarLink != "" {
            FileStorage.downloadImage(imageUrl: user.avatarLink) { (avatarImage) in
                self.avatarInageViewOutlet.image = avatarImage?.circleMasked
            }
        } else {
            self.avatarInageViewOutlet.image = UIImage(named: "avatar")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
