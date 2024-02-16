//
//  SettingsTableViewController.swift
//  Chat Clone
//
//  Created by Mohammed on 09/01/2024.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    
    
    //MARK:- IBoutlets
    
    @IBOutlet weak var avatarImagesOutlets: UIImageView!
    
    @IBOutlet weak var usernamelabeloutlets: UILabel!
    
    
    @IBOutlet weak var statuslabeloutlets: UILabel!
    
    @IBOutlet weak var appVersionLabelOutlets: UILabel!
    
    //MARK:- Lifecycle of table view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showUserInfo()
        
    }
    
    
    
    //MARK:- IB Action
    
    @IBAction func tellFriendBtnTapped(_ sender: UIButton) {
        print("tell")
    }
    
    
    @IBAction func ternsBtnTapped(_ sender: UIButton) {
        print("terns")
    }
    
    @IBAction func logOutBtnTapped(_ sender: UIButton) {
        FUserListener.shared.logoutCurrentUser { (error) in
            if error == nil {
                let loginView = UIStoryboard(name: "main", bundle: nil).instantiateViewController(withIdentifier: "LoginView")
                
                DispatchQueue.main.async {
                    loginView.modalPresentationStyle = .fullScreen
                    self.present(loginView, animated: true, completion: nil)
                }
                
                
            }
        }
    }
    
    //MARK:- Tableview Delegates
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "TableView")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0: 10.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            
            performSegue(withIdentifier: "SettingsToEditProfileSegue", sender: self)
        }
    }
    
    
    
    //MARK:- Ubdate Ui
    
    private func showUserInfo() {
        if let user = User.currentUser {
            usernamelabeloutlets.text = user.username
            statuslabeloutlets.text = user.status
            appVersionLabelOutlets.text = "App Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
            
            if user.avatarLink != "" {
                //TODO: Download and set avatar image
                FileStorage.downloadImage(imageUrl: user.avatarLink) { (avatarImage) in
                    self.avatarImagesOutlets.image = avatarImage?.circleMasked
                    
                }
            }
        }
    }

}


