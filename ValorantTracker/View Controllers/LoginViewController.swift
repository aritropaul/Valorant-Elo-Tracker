//
//  LoginViewController.swift
//  ValorantTracker
//
//  Created by Aritro Paul on 12/01/21.
//

import UIKit

protocol LoginDelegate : class {
    func didPerformLogin()
}

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    weak var delegate : LoginDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = false
        // Do any additional setup after loading the view.
    }

    @IBAction func loginTapped(_ sender: Any) {
        username = usernameField.text ?? ""
        password = passwordField.text ?? ""
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(password, forKey: "password")
        self.dismiss(animated: true) {
            self.delegate?.didPerformLogin()
        }
    }
}
