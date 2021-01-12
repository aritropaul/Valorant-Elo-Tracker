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
    weak var delegate: LoginDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
