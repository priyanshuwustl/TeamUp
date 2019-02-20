//
//  MatchedTableViewController.swift
//  TeamUp
//
//  Created by Jackie Wong on 12/1/18.
// Last edited by Jessika Baral on 12/1/18
//  Copyright © 2018 STSAdmin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class MatchedTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    let ref = Database.database().reference(withPath: "users")
    let matchedRef = Database.database().reference(withPath: "matched")
    var currentUserID = ""
    var matches = [User]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "tableToDetailedMatch", sender: self)
        //self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem("back")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableToDetailedMatch" {
            let indexPath = tableView.indexPathForSelectedRow!
            let fName = matches[indexPath.row].firstName
            let lName = matches[indexPath.row].lastName
            let courses = matches[indexPath.row].coursesTaken
            let skills = matches[indexPath.row].skills
            let availability = matches[indexPath.row].availability
            let location = matches[indexPath.row].location
            let descrip = matches[indexPath.row].description
            let email = matches[indexPath.row].email
            let phoneNum = matches[indexPath.row].phoneNumber
            let nextVC = segue.destination as? matchesViewController
            nextVC?.fName = fName
            nextVC?.lName = lName
            nextVC?.courses = courses
            nextVC?.skills = skills
            nextVC?.availability = availability
            nextVC?.location = location
            nextVC?.descrip = descrip
            nextVC?.email = email
            nextVC?.phoneNum = phoneNum
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = UITableViewCell(style: .subtitle, reuseIdentifier: "myCell")
        let userTemp = matches[indexPath.row]
        myCell.textLabel!.text = userTemp.firstName
        return myCell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentUserEmail: String = (Auth.auth().currentUser?.email)!
        ref.queryOrdered(byChild: "email").queryEqual(toValue: currentUserEmail).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            self.currentUserID="\(snapshot.key)"

            self.matchedRef.child(self.currentUserID).observe(.value, with: { snapshot in
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot {
                        print(snapshot.key)
                        self.ref.child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
                            if (snapshot.value as? [String: AnyObject]) != nil {
                                if let childUser = User(snapshot: snapshot) {
                                    var inTable = false
                                    for match in self.matches {
                                        if(match.uid == childUser.uid){
                                            inTable = true
                                        }
                                    }
                                    if !inTable {
                                        self.matches.append(childUser)
                                        self.tableView.reloadData()
                                    }
                                }
                         
                            }
                        })
                    }
                }
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
