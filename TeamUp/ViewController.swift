//
//  ViewController.swift
//  TeamUp
//
//  Created by STSAdmin on 11/13/18.
//  Copyright © 2018 STSAdmin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class ViewController: UIViewController {
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet var createAccountBtn: UIButton!
    
    @IBAction func signUp(_ sender: Any) {
         //self.performSegue(withIdentifier: "logInToCreation", sender: nil)
    }
    @IBAction func pressCreateAccount(_ sender: Any) {
      
    }
    
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBAction func logIn(_ sender: Any) {
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, error) in
            if error==nil{
                self.performSegue(withIdentifier: "logInToHome", sender: nil)
                print("signed in")
                
            }
            else{
                // print(error)
                self.createAlert(title: "Error", message: (error?.localizedDescription)!)
            }
        }
    }
    
    func createAlert(title:String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        password.isSecureTextEntry = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            // ...
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

