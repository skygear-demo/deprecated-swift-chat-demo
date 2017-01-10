//
//  SettingsViewController.swift
//  Swift Chat Demo
//
//  Created by atwork on 1/12/2016.
//  Copyright © 2016 Skygear. All rights reserved.
//

import UIKit
import SKYKitChat

class SettingsViewController: UITableViewController {

    @IBOutlet weak var logoutTableViewCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == tableView.indexPath(for: logoutTableViewCell) {
            let alert = UIAlertController(title: "",
                                          message: "This will remove account information from this device.",
                                          preferredStyle: .actionSheet)
            let logoutAction = UIAlertAction(title: "Logout", style: .destructive, handler: { (action) in
                SKYContainer.default().logout(completionHandler: { (_, _) in

                })
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(logoutAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
