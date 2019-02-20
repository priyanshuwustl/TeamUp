//
//  matchesViewController.swift
//  Displays the detailed user profile of a logged-in user's matches
//
//  Created by Jackie Wong on 12/1/18.
//  Copyright © 2018 Jackie Wong. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class matchesViewController: UIViewController {
    
    var fName: String!
    var lName: String!
    var phoneNum: String!
    var email: String!
    var courses: String!
    var skills: String!
    var availability: String!
    var location: String!
    var descrip: String!
    
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var coursesTextView: UITextView!
    @IBOutlet weak var skillsTextView: UITextView!
    @IBOutlet weak var availabilityTextView: UITextView!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    let backButton = UIBarButtonItem()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDetailsOfMatch()
        //let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.tabBarController?.navigationItem.leftBarButtonItem=backButton
        backButton.target = self
        backButton.action = #selector(backButtonClicked)
        //self.tabBarController?.navigationItem.rightBarButtonItem?.action = #selector(logoutButtonClicked)
    }
    
    @objc func backButtonClicked(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        backButton.tintColor = UIColor.clear
    }
    
//    @objc func logoutButtonClicked(sender: UIBarButtonItem) {
//        //let user = Auth.auth().currentUser!
//        print("LOGOUT BUTTON CLICKED")
//        do {
//            try Auth.auth().signOut()
//            self.dismiss(animated: true, completion: nil)
//            //let tabBarController = self.tabBarController
//            //self.performSegue(withIdentifier: "logout", sender: nil)
//            print(Auth.auth().currentUser!)
//        } catch (let error) {
//            print("Auth sign out failed: \(error)")
//        }
//    }
//    
    func updateDetailsOfMatch() {
        firstName.text = fName
        lastName.text = lName
        phoneNumber.text = phoneNum
        emailLabel.text = email
        coursesTextView.text! = courses
        skillsTextView.text! = skills
        availabilityTextView.text! = availability
        locationTextView.text! = location
        descriptionTextView.text! = descrip
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
