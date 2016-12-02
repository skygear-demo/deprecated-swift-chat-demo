//
//  YourNameViewController.swift
//  Swift Chat Demo
//
//  Created by atwork on 1/12/2016.
//  Copyright © 2016 Skygear. All rights reserved.
//

import UIKit
import SKYKit

class ChangeNameViewController: UIViewController, UITextFieldDelegate {
    
    let container = SKYContainer.default()
    let helper = ChatHelper.shared
    
    @IBOutlet weak var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let userRecord = helper.currentUserRecord {
            self.nameField.text = userRecord.chat_versatileNameOfUserRecord
        }
        nameField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recrdeated.
    }
    
    @IBAction func didTapDone(_ sender: Any) {
        self.saveChanges()
    }
    
    func saveChanges() {
        guard let userRecord = helper.currentUserRecord else {
            return
        }
        
        userRecord.setValue(nameField.text, forKey: "name")
        container?.publicCloudDatabase.save(userRecord, completion: { (savedUserRecord, error) in
            if let theError = error {
                let alert = UIAlertController(title: "Unable to Save",
                                  message: theError.localizedDescription,
                                  preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            

            self.helper.cacheUserRecord(savedUserRecord)
            let _ = self.navigationController?.popViewController(animated: false)
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveChanges()
        return false
    }
}
