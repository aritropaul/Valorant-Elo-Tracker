//
//  SettingsViewController.swift
//  ValorantTracker
//
//  Created by Aritro Paul on 06/01/21.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.text = username
        passwordField.text = password
        
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        if username != usernameField.text || password != passwordField.text {
            userChanged = true
        }
        username = usernameField.text ?? ""
        password = passwordField.text ?? ""
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(password, forKey: "password")
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if username != usernameField.text || password != passwordField.text {
            userChanged = true
        }
        username = usernameField.text ?? ""
        password = passwordField.text ?? ""
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(password, forKey: "password")
    }
}
