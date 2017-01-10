//
//  LoginViewController.swift
//  Swift Chat Demo
//
//  Created by atwork on 1/12/2016.
//  Copyright © 2016 Skygear. All rights reserved.
//

import UIKit
import SKYKit

protocol LoginViewControllerDelegate {
    func loginViewController(_ viewController: LoginViewController, didFinishWithUser user: SKYUser)
}

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var flowSegmentedControl: UISegmentedControl!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    var delegate: LoginViewControllerDelegate?
    var theUserRecord: SKYRecord?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.updateLoginButton()

        usernameField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateLoginButton() {
        let buttonDisplayText = isNewUser ? "Sign Up" : "Login"
        self.loginButton.setTitle(buttonDisplayText, for: .normal)
        self.loginButton.isEnabled = !usernameField.text!.isEmpty && !passwordField.text!.isEmpty
    }

    var isNewUser: Bool {
        return flowSegmentedControl.selectedSegmentIndex == 0
    }

    var container: SKYContainer {
        return SKYContainer.default()!
    }

    @IBAction func toggleFlow(_ sender: Any) {
        updateLoginButton()
    }

    @IBAction func tapLoginButton(_ sender: Any) {
        performLoginAction()
    }

    func performLoginAction() {
        guard let username = usernameField.text else {
            return
        }
        guard let password = passwordField.text else {
            return
        }

        if isNewUser {
            container.signup(withUsername: username,
                             password: password) { (user, error) in
                                self.handleLoginResponse(user: user, error: error)
            }
        } else {
            container.login(withUsername: username,
                            password: password) { (user, error) in
                                self.handleLoginResponse(user: user, error: error)
            }
        }
    }

    func handleLoginResponse(user: SKYUser?, error: Error?) {
        if error != nil {
            self.presentLoginAlert(error: error!)
            return
        }

        if let theUser = user {
            if isNewUser {
                let userRecord = SKYRecord(recordType: "user",
                                           name: theUser.userID,
                                           data: ["name": theUser.username])
                container.publicCloudDatabase.save(userRecord, completion: { (savedUserRecord, _) in
                    ChatHelper.shared.cacheUserRecord(savedUserRecord)
                    self.delegate?.loginViewController(self, didFinishWithUser: theUser)
                })
            } else {
                delegate?.loginViewController(self, didFinishWithUser: theUser)
            }
        }
    }

    func presentLoginAlert(error: Error) {
        let title = isNewUser ? "Unable to Sign Up" : "Unable to Login"
        let alert = UIAlertController(title: title,
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.passwordField.text = ""
            self.passwordField.becomeFirstResponder()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func usernameFieldDidChange(_ sender: Any) {
        self.updateLoginButton()
    }

    @IBAction func passwordFieldDidChange(_ sender: Any) {
        self.updateLoginButton()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            if self.loginButton.isEnabled {
                performLoginAction()
                passwordField.resignFirstResponder()
            }
        }
        return false
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
