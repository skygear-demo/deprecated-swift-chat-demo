//
//  ChatHelper.swift
//  Swift Chat Demo
//
//  Created by atwork on 1/12/2016.
//  Copyright © 2016 Skygear. All rights reserved.
//

import UIKit
import SKYKit

class ChatHelper: NSObject {

    private static let sharedHelper = ChatHelper()
    private var container = SKYContainer.default()!
    private var userRecords: [String: SKYRecord] = [:]

    class var shared: ChatHelper {
        return sharedHelper
    }

    override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.SKYContainerDidChangeCurrentUser,
                                               object: nil,
                                               queue: OperationQueue.main) { (note) in
                                                self.fetchCurrentUserRecord(completion: { (_) in

                                                })
                                                self.userRecords = [:]
        }
    }

    var isLoggedIn: Bool {
        return container.currentUser != nil
    }

    var currentUserRecord: SKYRecord? {
        guard isLoggedIn else {
            return nil
        }
        return userRecords[container.currentUserRecordID]
    }

    func userRecord(userID: String) -> SKYRecord? {
        return userRecords[userID]
    }

    func userRecords(userIDs: [String]) -> [SKYRecord] {
        var records: [SKYRecord] = []
        userIDs.forEach { (value) in
            if let record = self.userRecords[value] {
                records.append(record)
            }
        }
        return records
    }

    func fetchCurrentUserRecord(completion: ((_ userRecord: SKYRecord?) -> Void)?) {
        if !isLoggedIn {
            completion?(nil)
            return
        }

        fetchUserRecords(userIDs: [container.currentUserRecordID]) { (records, _) in
            completion?(records?.first)
        }
    }

    func fetchUserRecords(userIDs: [String], completion: ((_ userRecords: [SKYRecord]?, _ error: Error?) -> Void)?) {
        let recordIDs = userIDs.map { (value) -> SKYRecordID in
            return SKYRecordID(recordType: "user", name: value)
        }

        let db = SKYContainer.default().publicCloudDatabase!
        db.fetchRecords(withIDs: recordIDs, completionHandler: { (usermap, error) in
            if error != nil {
                completion?(nil, error)
                return
            }

            guard let usermap = usermap else {
                return
            }

            var newUserRecords: [SKYRecord] = []
            for (_, v) in usermap {
                if let record = v as? SKYRecord {
                    newUserRecords.append(record)
                    self.userRecords[record.recordID.recordName] = record
                }
            }

            completion?(newUserRecords, nil)
        }, perRecordErrorHandler: nil)
    }

    func cacheUserRecords(_ userRecords: [SKYRecord]) {
        for userRecord in userRecords {
            self.userRecords[userRecord.recordID.recordName] = userRecord
        }
    }

    func cacheUserRecord(_ userRecord: SKYRecord?) {
        guard let theUserRecord = userRecord else {
            return
        }

        self.userRecords[theUserRecord.recordID.recordName] = theUserRecord
    }

    func generateConversationDefaultTitle(participantIDs: [String], includeCurrentUserName: Bool) -> String {
        let participants = participantIDs.filter { (userID) -> Bool in
            return userID != SKYContainer.default().currentUserRecordID || includeCurrentUserName
        }
        let names = participants.flatMap { (userID) -> SKYRecord? in
            return ChatHelper.shared.userRecord(userID: userID)
        }.flatMap { (record) -> String? in
            return record.chat_nameOfUserRecord
        }

        let joinedName = names.joined(separator: ", ")
        if names.count == 0 {
            return "\(participants.count) participants"
        } else if names.count < participants.count {
            let diff = participants.count - names.count
            return "\(joinedName) + \(diff) participants"
        } else {
            return joinedName
        }

    }
}
