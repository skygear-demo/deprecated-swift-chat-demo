//
//  SKYRecordExtension.swift
//  Swift Chat Demo
//
//  Created by atwork on 2/12/2016.
//  Copyright © 2016 Skygear. All rights reserved.
//

import UIKit
import SKYKit

extension SKYRecord {
    var chat_nameOfUserRecord: String? {
        guard self.recordID.recordType == "user" else {
            return nil
        }
        
        return self.value(forKey: "name") as! String?
    }

    var chat_versatileNameOfUserRecord: String? {
        if let name = self.chat_nameOfUserRecord {
            return name
        } else {
            return "Unknown User"
        }
    }

}
