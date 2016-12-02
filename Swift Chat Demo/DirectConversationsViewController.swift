//
//  DirectConversationsViewController.swift
//  Swift Chat Demo
//
//  Created by atwork on 1/12/2016.
//  Copyright © 2016 Skygear. All rights reserved.
//

import UIKit
import SKYKit
import SKYKitChat

class DirectConversationsViewController: UsersViewController {
    
    var userConversations: [SKYRecordID: SKYUserConversation] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func findOrCreateConversation(userRecord: SKYRecord, completion: @escaping (_ userConversation: SKYUserConversation?, _ error: Error?) -> Void) {
        if let userConversation = self.userConversations[userRecord.recordID] {
            completion(userConversation, nil)
            return
        }
        
        chat.createDirectConversation(userID: userRecord.recordID.recordName,
                                      title: "",
                                      metadata: nil) { (c, err) in
                                        if let error = err {
                                            completion(nil, error)
                                            return
                                        }
                                        
                                        if let userConversation = c {
                                            self.userConversations[userRecord.recordID] = userConversation
                                            completion(userConversation, nil)
                                        }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath)
        guard let userRecord = self.userRecord(indexPath: indexPath) else {
            return cell
        }
        
        cell.textLabel?.text = userRecord.chat_versatileNameOfUserRecord
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "open_conversation", let messagesVC = segue.destination as? MessagesViewController {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell), let user = userRecord(indexPath: indexPath) {
                self.findOrCreateConversation(userRecord: user, completion: { (uc, err) in
                    if let userConversation = uc {
                        messagesVC.start(withUserConversation: userConversation)
                    }
                })
            }

        }
    }
}
