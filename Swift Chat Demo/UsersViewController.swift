//
//  OtherUsersViewController.swift
//  Swift Chat Demo
//
//  Created by atwork on 1/12/2016.
//  Copyright © 2016 Skygear. All rights reserved.
//

import UIKit
import SKYKit
import SKYKitChat

class UsersViewController: UITableViewController {
    
    var allowDeleting: Bool = true
    let helper: ChatHelper = ChatHelper.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.SKYContainerDidChangeCurrentUser,
                                               object: nil,
                                               queue: OperationQueue.main) { (note) in
                                                self.clearAllUserRecords()
        }

        self.updateUserRecords()
    }
    
    var chat: SKYChatExtension = SKYContainer.default().chatExtension()!
    
    var userRecordIDs: [String] {
        get {
            guard let userRecordNames = UserDefaults().stringArray(forKey: "other_users") else {
                return []
            }
            
            return userRecordNames
//            var ids: [SKYRecordID] = []
//            for name in userRecordNames {
//                ids.append(SKYRecordID(recordType: "user", name: name))
//            }
//            return ids
        }
        
        set(value) {
//            var ids: [String] = []
//            
//            for recordID in value {
//                ids.append(recordID.recordName)
//            }

            UserDefaults().setValue(value, forKey: "other_users")
            UserDefaults().synchronize()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clearAllUserRecords() {
        self.userRecordIDs = []
    }
    
    func updateUserRecords() {
        guard self.userRecordIDs.count > 0 else {
            return
        }
        
        helper.fetchUserRecords(userIDs: userRecordIDs) { (_, _) in
            self.tableView.reloadData()
        }
    }

    @IBAction func tapAddButton(_ sender: Any) {
        self.chat_startSearchUserFlow { (record) in
            guard let foundUser:SKYRecord = record else {
                return
            }
            
            guard !self.userRecordIDs.contains(foundUser.recordID.recordName) else {
                print("User already added to list")
                return
            }
            
            self.userRecordIDs.append(foundUser.recordID.recordName)
            self.tableView.insertRows(at: [IndexPath.init(row: self.userRecordIDs.count - 1, section: 0)],
                                      with: UITableViewRowAnimation.automatic)

        }
    }
    
    func userRecord(indexPath: IndexPath) -> SKYRecord? {
        guard indexPath.row < userRecordIDs.count else {
            return nil
        }
        return helper.userRecord(userID: userRecordIDs[indexPath.row])
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRecordIDs.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return allowDeleting
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let userRecord = self.userRecord(indexPath: indexPath) else {
            return;
        }
        
        if editingStyle == .delete {
            if let index = userRecordIDs.index(of: userRecord.recordID.recordName) {
                userRecordIDs.remove(at: index)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
