//
//  MessagesViewController.swift
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

class MessagesViewController: JSQMessagesViewController {
    
    var chat: SKYChatExtension = SKYContainer.default().chatExtension()!
    var conversation : SKYUserConversation? = nil
    var users: [String: SKYRecord]? = nil
    var messages : [SKYMessage] = []
    
    var incomingBubble :JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = SKYContainer.default().currentUserRecordID
        self.senderDisplayName = ChatHelper.shared.userRecord(userID: self.senderId)?.chat_versatileNameOfUserRecord
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.lightGray)
        outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    
        reloadViews()
    }
    
    func start(withUserConversation userConversation: SKYUserConversation) {
        self.conversation = userConversation
        self.navigationItem.title = conversation?.conversation.versatileTitle
        
        fetchMessages()
        fetchAllParticipants()
    }
    
    func reloadViews() {
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
    }
    
    func fetchMessages() {
        guard let conversation = self.conversation else {
            print("No conversation")
            return
        }
        chat.fetchMessages(conversation: conversation.conversation,
                            limit: 100,
                            beforeTime: nil,
                            completion: { (messages, error) in
                                if let err = error {
                                    let alert = UIAlertController(title: "Unable to load", message: err.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                    return
                                }
                                
                                if let messages = messages {
                                    self.messages = messages.reversed()
                                    self.reloadViews()
                                }
        })
    }
    
    func fetchAllParticipants() {
        let db = SKYContainer.default().publicCloudDatabase
        var userRecordIDs: [SKYRecordID] = []
        guard conversation != nil else {
            return
        }
        for recordName in (conversation?.conversation.participantIds)! {
            userRecordIDs.append(SKYRecordID(recordType: "user", name: recordName))
        }
        
        print("Fetching participants for the conversation: \(userRecordIDs)")
        
        db?.fetchRecords(withIDs: userRecordIDs,
                         completionHandler: { (usermap, err) in
                            var newUsers: [String : SKYRecord] = [:]
                            for (k, v) in usermap! {
                                guard let recordID = k as? SKYRecordID else {
                                    continue
                                }
                                guard let userRecord = v as? SKYRecord else {
                                    continue
                                }
                                newUsers[recordID.recordName] = userRecord
                            }
                            self.users = newUsers
                            self.reloadViews()
        }, perRecordErrorHandler: nil)
    }
    
    func isOutgoingSKYMessage(_ message: SKYMessage)-> Bool {
        return message.creatorUserRecordID == self.senderId
    }
    
    func findSender(of message: SKYMessage) -> SKYRecord? {
        guard let users = self.users else {
            print("No users fetched yet.")
            return nil
        }
        
        return users[message.creatorUserRecordID]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "details" {
            let detailsVC = segue.destination as! ConversationDetailViewController
            
            detailsVC.participantIDs = (conversation?.conversation.participantIds)!
            detailsVC.adminIDs = (conversation?.conversation.adminIds)!
            detailsVC.conversationID = conversation?.conversation.recordID.recordName
            detailsVC.allowAddingParticipants = !(conversation?.conversation.isDistinctByParticipants)!
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let message = messages[indexPath.row]
        var displayName:String? = ""
        if let user = findSender(of: message) {
            displayName = user.chat_versatileNameOfUserRecord
        }
        let data = JSQMessage(senderId: message.creatorUserRecordID,
                              senderDisplayName: displayName,
                              date: message.creationDate,
                              text: message.body)
        return data
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.row]
        return self.isOutgoingSKYMessage(message) ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        
        if !isOutgoingSKYMessage(message) {
            return nil;
        }
        
        switch (message.conversationStatus) {
        case .allRead:
            return NSAttributedString(string: "All read")
        case .someRead:
            return NSAttributedString(string: "Some read")
        case .delivered:
            return NSAttributedString(string: "Delivered")
        case .delivering:
            return NSAttributedString(string: "Delivering")
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {

        return 14;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        if let user = findSender(of: messages[indexPath.row]) {
            return JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: user["name"] as? String, backgroundColor: UIColor.gray, textColor: UIColor.white, font: UIFont.systemFont(ofSize: 12), diameter: 12)
        }
        return nil
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        // TODO: Add support for attaching image or other media files
        let alert = UIAlertController(title: "Not Supported", message: "Does not support attaching images at the moment", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {

        let message = SKYMessage()!
        message.body = text
        message.creatorUserRecordID = SKYContainer.default().currentUserRecordID
        chat.addMessage(message, to: (conversation?.conversation)!, completion: { (msg, _) in
            if let sentMessage = msg {
                guard let transientMessageIndex = self.messages.index(of: message) else {
                    return
                }
                
                self.messages[transientMessageIndex] = sentMessage
                let indexPath = IndexPath(index: transientMessageIndex)
//                self.collectionView.reloadItems(at: [indexPath])
                self.collectionView.reloadData()
            }
        })
        self.messages.append(message)
        self.finishSendingMessage(animated: true)
    }
}
