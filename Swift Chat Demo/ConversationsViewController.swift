//
//  ConversationsViewController.swift
//  Swift Chat Demo
//
//  Created by atwork on 29/11/2016.
//  Copyright © 2016 Skygear. All rights reserved.
//

import UIKit
import SKYKit
import SKYKitChat
import JSQMessagesViewController
import MBProgressHUD

class ConversationsViewController: UITableViewController, ConversationDetailViewControllerDelegate {

    var chat = SKYContainer.default().chatExtension
    var conversations: [SKYUserConversation] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchUserConversations(completion: nil)
        fetchTotalUnreadCount()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func fetchTotalUnreadCount() {
        chat?.fetchTotalUnreadCount(completion: { (dict, error) in
            if let unreadMessages = dict?["message"]?.intValue {
                self.navigationController?.tabBarItem.badgeValue = unreadMessages > 0 ? String(unreadMessages) : nil
            }
        })
    }
    func fetchUserConversations(completion: (() -> Void)?) {
        chat?.fetchUserConversations { (conversations, error) in
            if let err = error {
                let alert = UIAlertController(title: "Unable to load conversations", message: err.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if let fetchedConversations = conversations {
                print("Fetched \(fetchedConversations.count) user conversations.")
                self.conversations = fetchedConversations
            }
            
            self.tableView.reloadData()
            completion?()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "new_conversation" {
            let navigationController: UINavigationController = segue.destination as! UINavigationController
            let detailsVC: ConversationDetailViewController = navigationController.viewControllers.first as! ConversationDetailViewController
            detailsVC.participantIDs = [SKYContainer.default().currentUserRecordID]
            detailsVC.adminIDs = [SKYContainer.default().currentUserRecordID]
            detailsVC.allowLeaving = false
            detailsVC.showDismissalControls = true
            detailsVC.delegate = self
        } else if segue.identifier == "open_conversation", let messagesVC = segue.destination as? MessagesViewController {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                messagesVC.start(withUserConversation: self.conversations[indexPath.row])
            } else {
                // Presenting view controller for new conversation. New conversation
                // is the first conversation in the table view.
                messagesVC.start(withUserConversation: self.conversations[0])
            }
        }
    }

    func presentMessagesViewController(withUserConversation userConversation: SKYUserConversation) {
        let messagesVC = MessagesViewController()
        messagesVC.senderId = SKYContainer.default().currentUserRecordID
        messagesVC.senderDisplayName = ""
        messagesVC.conversation = userConversation
        self.navigationController?.pushViewController(messagesVC, animated: true)
    }

    @IBAction func refreshControlDidRefresh(_ sender: Any) {
        self.fetchUserConversations {
            self.refreshControl?.endRefreshing()
        }
    }

    func conversationDetailViewController(didCancel viewController: ConversationDetailViewController) {
        self.dismiss(animated: true, completion: nil)
    }

    func conversationDetailViewController(didFinish viewController: ConversationDetailViewController) {
        self.dismiss(animated: true, completion: nil)

        let participantIDs = viewController.participantIDs
        let title = ChatHelper.shared.generateConversationDefaultTitle(participantIDs: participantIDs,
                                                                       includeCurrentUserName: true)
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        chat?.createConversation(participantIDs: viewController.participantIDs,
                                 title: title,
                                 metadata: nil,
                                 completion: { (userConversation, error) in
                                    hud.hide(animated: true)
                                    if error != nil {
                                        let alert = UIAlertController(title: "Unable to Create",
                                                                      message: error!.localizedDescription,
                                                                      preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                        return
                                    }
                                    
                                    self.conversations.insert(userConversation!, at: 0)
                                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)],
                                                              with: .automatic)
                                    
                                    self.performSegue(withIdentifier: "open_conversation", sender: self)
                                    
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return conversations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversation", for: indexPath)

        let userConversation = conversations[indexPath.row]

        // Configure the cell...
        cell.textLabel?.text = userConversation.conversation.versatileTitle
        cell.detailTextLabel?.text = userConversation.unreadCount > 0 ? String(userConversation.unreadCount) : ""
        return cell
    }

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
