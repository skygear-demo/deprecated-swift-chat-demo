//
//  SKYConversationExtension.swift
//  Swift Chat Demo
//
//  Created by atwork on 1/12/2016.
//  Copyright © 2016 Skygear. All rights reserved.
//

import SKYKitChat

extension SKYConversation {
    var versatileTitle: String {
        if (!(self.title ?? "").isEmpty) {
            return self.title!
        }
        
        return ChatHelper.shared.generateConversationDefaultTitle(participantIDs: self.participantIds,
                                                                  includeCurrentUserName: false)
    }
}
