//
//  NewMessageController.swift
//  ChatApp
//
//  Created by Daniel Collazo on 5/8/17.
//  Copyright © 2017 Daniel Collazo. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUser()
        
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.id = snapshot.key
                //if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                print(user.name ?? "", user.email ?? "")
                
                // This will crash because of background thread, so lets use dispatch_async to fix
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        }, withCancel: nil)
    }
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // lets use a hack for now, actually need to dequeue cell for memory effeciency
        // let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email

        
        if let profileImageUrl = user.profileImageUrl {
            
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            
//            let url = URL(string: profileImageUrl)
//            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
//                
//                // Download hit an error so lets return out
//                if error != nil {
//                    print(error ?? "Profile image download hit an error.")
//                    return
//                }
//                
//                DispatchQueue.main.async {
//                    cell.profileImageView.image = UIImage(data: data!)
//                }
//            }).resume()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true)
        print("Dismiss completed.")
        let user = self.users[indexPath.row]
        self.messagesController?.showChatControllerForUser(user: user)
    }
}

