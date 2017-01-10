//
//  RootViewController.swift
//  Swift Chat Demo
//
//  Created by atwork on 1/12/2016.
//  Copyright © 2016 Skygear. All rights reserved.
//

import UIKit
import SKYKit

class RootViewController: UITabBarController, LoginViewControllerDelegate {

    var container = SKYContainer.default()!
    var overlayView: UIView? = nil
    let helper = ChatHelper.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        NotificationCenter.default.addObserver(forName: NSNotification.Name.SKYContainerDidChangeCurrentUser,
                                               object: nil,
                                               queue: OperationQueue.main) { (note) in
                                                if !self.helper.isLoggedIn && !self.loginViewControllerPresenting {
                                                    self.presentLoginViewController(animated: true)
                                                }
        }

        if !helper.isLoggedIn {
            overlayView = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()?.view
            overlayView?.frame = self.view.bounds
            overlayView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            self.view.addSubview(overlayView!)
        }
        helper.fetchCurrentUserRecord { (_) in

        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !helper.isLoggedIn {
            presentLoginViewController(animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var loginViewControllerPresenting: Bool {
        return self.presentedViewController != nil
    }

    func presentLoginViewController(animated: Bool) {
        if (animated) {
            self.performSegue(withIdentifier: "login", sender: self)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LoginNavigationController") as! UINavigationController
            self.setLoginViewControllerDelegate(navigationController: controller)
            self.present(controller, animated: false, completion: {
                self.overlayView?.removeFromSuperview()
                self.overlayView = nil
            })
        }
    }

    func setLoginViewControllerDelegate(navigationController: UINavigationController) {
        let loginVC = navigationController.viewControllers.first as? LoginViewController
        loginVC?.delegate = self
    }

    func loginViewController(_ viewController: LoginViewController, didFinishWithUser user: SKYUser) {
        self.dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "login" {
            self.setLoginViewControllerDelegate(navigationController: segue.destination as! UINavigationController)
        }
    }

}
