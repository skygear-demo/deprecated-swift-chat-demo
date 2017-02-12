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

    var chat: SKYChatExtension = SKYContainer.default().chatExtension!
    var conversation: SKYUserConversation? = nil
    var users: [String: SKYRecord]? = nil
    var messages: [SKYMessage] = []
    var lastTypingEvent: SKYChatTypingEvent?
    var lastTypingEventDate: Date?

    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!

    var messageObserver: Any?
    var typingObserver: Any?

    var typingPromptTimer: Timer?

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

        subscribeToNotifications()
        fetchMessages()
        fetchAllParticipants()
    }

    deinit {
        unsubscribeFromNotifications()
    }

    func subscribeToNotifications() {
        guard let userConversation = self.conversation else {
            return
        }
        messageObserver = chat.subscribeToMessages(in: userConversation.conversation, handler: { (event, message) in
            print("Received message event")
            if event == SKYChatRecordChangeEvent.create && !self.messages.contains(message) && message.creatorUserRecordID != SKYContainer.default().currentUserRecordID
            {
                self.messages.append(message)
                self.reloadViews()
                self.finishReceivingMessage(animated: true)
            }
        })
        typingObserver = chat.subscribeToTypingIndicator(in: userConversation.conversation, handler: { (indicator) in
            print("Receiving typing event")
            self.promptTypingIndicator(indicator)
        })
    }

    func unsubscribeFromNotifications() {
        if let observer = messageObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = typingObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func promptTypingIndicator(_ indicator: SKYChatTypingIndicator) {
        if let timer = typingPromptTimer {
            timer.invalidate()
            typingPromptTimer = nil
        }

        var typingUserDisplayName: String?
        let typingUserIDs = indicator.typingUserIDs
        if typingUserIDs.count == 0 {
            // No one is typing.
            self.navigationItem.prompt = nil;
            return;
        } else if typingUserIDs.count == 1 {
            if let typingUser = ChatHelper.shared.userRecord(userID: typingUserIDs.first!) { // Get the first user record by first ID in typingUserIDs
                typingUserDisplayName = typingUser.chat_nameOfUserRecord // Get the displayname of the user record
            }
            
            if typingUserDisplayName != nil {
                self.navigationItem.prompt = "\(typingUserDisplayName!) is typing..."
            } else {
                self.navigationItem.prompt = "Someone is typing..."
            }
        } else {
            self.navigationItem.prompt = "Some people are typing..."
        }
        typingPromptTimer = Timer.scheduledTimer(withTimeInterval: 10.0,
                                       repeats: false,
                                       block: { (_) in
                                        self.navigationItem.prompt = nil
        })

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

    }

    func fetchAllParticipants() {
        let db = SKYContainer.default().publicCloudDatabase
        var userRecordIDs: [SKYRecordID] = []
        guard conversation != nil else {
            return
        }

        print("Fetching participants for the conversation: \(userRecordIDs)")

    }

    func isOutgoingSKYMessage(_ message: SKYMessage) -> Bool {
        return message.creatorUserRecordID == self.senderId
    }

    func findSender(of message: SKYMessage) -> SKYRecord? {
        guard let users = self.users else {
            print("No users fetched yet.")
            return nil
        }

        return users[message.creatorUserRecordID]
    }
    
    func triggerTypingEvent(_ event: SKYChatTypingEvent) {
        if event == lastTypingEvent {
            if lastTypingEventDate != nil && lastTypingEventDate!.timeIntervalSinceNow > -1 {
                // Last event is published less than 1 second ago.
                // Throttle so the server is not overwhelmed with typing events.
                return
            }
        } else if event == .pause && event != .begin {
            // No need to send the pause typing event when typing not yet started.
            return
        }
        chat.sendTypingIndicator(event, in: (conversation?.conversation)!)
        lastTypingEvent = event
        lastTypingEventDate = Date.init()
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
        var displayName: String? = ""
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
            return nil
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

        return 14
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {

        if let user = findSender(of: messages[indexPath.row]) {
            return JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: user["name"] as? String, backgroundColor: UIColor.gray, textColor: UIColor.white, font: UIFont.systemFont(ofSize: 12), diameter: 12)
        }
        return nil
    }

    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        triggerTypingEvent(.begin)
    }

    override func textViewDidEndEditing(_ textView: UITextView) {
        super.textViewDidEndEditing(textView)
        triggerTypingEvent(.pause)
    }

    override func didPressAccessoryButton(_ sender: UIButton!) {
        // TODO: Add support for attaching image or other media files
        let alert = UIAlertController(title: "Not Supported", message: "Does not support attaching images at the moment", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // We need to firstly create a SKYMessage object with body, creatorUserRecordID.
        let message = SKYMessage()!
        message.body = text
        message.creatorUserRecordID = SKYContainer.default().currentUserRecordID // The creator ID is the ID of the current user
        // Send the message to the conversation
        chat.addMessage(message, to: (conversation?.conversation)!, completion: { (msg, _) in
            if let sentMessage = msg {
                guard let transientMessageIndex = self.messages.index(of: message) else {
                    return
                }
                
                self.messages[transientMessageIndex] = sentMessage
                self.collectionView.reloadData()
            }
        })
        self.messages.append(message)
        self.finishSendingMessage(animated: true)
        triggerTypingEvent(.finished)
    }
}
