//
//  ConversationDetailViewController.swift
//  Swift Chat Demo
//
//  Created by atwork on 2/12/2016.
//  Copyright © 2016 Skygear. All rights reserved.
//

import UIKit
import SKYKit
import MBProgressHUD

protocol ConversationDetailViewControllerDelegate {
    func conversationDetailViewController(didCancel viewController: ConversationDetailViewController)
    func conversationDetailViewController(didFinish viewController: ConversationDetailViewController)
}

class ConversationDetailViewController: UITableViewController {
    
    var conversationID: String?
    var participantIDs: [String] = []
    var adminIDs: [String] = []
    var allowEditing: Bool = true
    var allowAddingParticipants: Bool = true
    var allowLeaving: Bool = true
    var showDismissalControls: Bool = false
    var delegate: ConversationDetailViewControllerDelegate?
    
    var participantSection: Int {
        return 0
    }
    
    var leaveSection: Int {
        return allowLeaving ? participantSection + 1 : -1
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if showDismissalControls {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonDidTap))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonDidTap))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonDidTap(_ sender: Any) {
        delegate?.conversationDetailViewController(didCancel: self)
    }
    
    @IBAction func doneButtonDidTap(_ sender: Any) {
        delegate?.conversationDetailViewController(didFinish: self)
    }
    
    func leaveConversation(confirmed: Bool) {
        guard confirmed else {
            let alert = UIAlertController(title: "",
                                          message: "This will remove yourselves from this conversation",
                                          preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "Leave Conversation",
                                         style: .destructive,
                                         handler: { (action) in
                self.leaveConversation(confirmed: true)
            })
            alert.addAction(okAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        let chat = SKYContainer.default().chatExtension()!
        chat.leave(conversationID: conversationID!) { (error) in
            hud.hide(animated: true)
            if error != nil {
                let alert = UIAlertController(title: "Unable to Leave Conversation",
                                              message: error!.localizedDescription,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let _ = self.navigationController?.popToRootViewController(animated: true)
        }

    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return [participantSection, leaveSection].filter({ (value) -> Bool in
            return value >= 0
        }).count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == participantSection {
            return participantIDs.count + (allowEditing && allowAddingParticipants ? 1 : 0)
        } else if section == leaveSection {
            return 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == participantSection {
            if indexPath.row == participantIDs.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "add_new", for: indexPath)
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "participant", for: indexPath)
            let userID = participantIDs[indexPath.row]
            cell.textLabel?.text = ChatHelper.shared.userRecord(userID: userID)?.chat_versatileNameOfUserRecord
            cell.detailTextLabel?.text = adminIDs.contains(userID) ? "Admin" : ""
            return cell
        } else if indexPath.section == leaveSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: "leave_conversation", for: indexPath)
            return cell
        }
        return UITableViewCell(style: .default, reuseIdentifier: "unknown")
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == participantSection {
            return "Participants"
        }
        return ""
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == participantSection {
            guard indexPath.row < participantIDs.count else {
                return false
            }
            let userID = participantIDs[indexPath.row]
            return allowEditing && userID != SKYContainer.default().currentUserRecordID
        }
        return false
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            participantIDs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == participantSection && indexPath.row == participantIDs.count {
            chat_startSearchUserFlow(completion: { (record) in
                if let foundUser = record {
                    if self.participantIDs.contains(foundUser.recordID.recordName) {
                        return;
                    }
                    
                    self.participantIDs.append(foundUser.recordID.recordName)
                    let indexPath = IndexPath(row: self.participantIDs.count - 1,
                                              section: self.participantSection)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                }
            })
        } else if indexPath.section == leaveSection {
            leaveConversation(confirmed: false)
        }
    }

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
