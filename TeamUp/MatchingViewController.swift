//
//  MatchingViewController.swift
//  TeamUp
//
//  Created by Priyanshu on 28/11/18.
//  Code taken and modified from: Phill Farrugia
//  Copyright © 2018 STSAdmin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class MatchingViewController: UIViewController,UISearchBarDelegate, SwipeableCardViewDataSource{
   
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet private weak var swipeableCardView: SwipeableCardViewContainer!
    
    var users: [User] = []
    var user: User!
    let ref = Database.database().reference(withPath: "users")
    var currentUser = ""
    var currentUID = ""
    
    
    func createAlert(title:String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        searchBar.delegate = self
       
        
        swipeableCardView.dataSource = self
        
        //var currentUID = ""
        let currentUserEmail: String = (Auth.auth().currentUser?.email)!
        DispatchQueue.global(qos: .userInitiated).async{
        //var currentUser = ""
        
        self.ref.queryOrdered(byChild: "email").queryEqual(toValue: currentUserEmail).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            self.currentUID="\(snapshot.key)"
            
            self.ref.observe(.value, with: { snapshot in
                let newUsers: [User] = []
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                        let childUser = User(snapshot: snapshot) {
                        self.currentUser = (Auth.auth().currentUser?.email)!
                        var alreadySwiped = false
                        let swipesRef = Database.database().reference(withPath: "swipes")
                        let otherUserSwipesRef = swipesRef.child(childUser.uid)
                        print( otherUserSwipesRef.child(self.currentUID))
                        otherUserSwipesRef.child(self.currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
                            if (snapshot.value as? [String: AnyObject]) != nil {
                                alreadySwiped = true
                            }
                            
                            //update the matching view with the cards of users that they haven't swiped right on
                            if self.currentUser != childUser.email && !alreadySwiped{
                                self.users.append(childUser)
                                self.swipeableCardView.reloadData()
                            }
                        })
                    }
                }
                self.users = newUsers
                self.swipeableCardView.reloadData()
                
            })
            
        })
            DispatchQueue.main.async{
                self.swipeableCardView.reloadData()
            }
        }
       
        
        
        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)
            let currentUserRef = self.ref.child(self.user.uid)
            currentUserRef.onDisconnectRemoveValue()
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        if let search = searchBar.text {
            if search == "" {
                 self.createAlert(title: "Enter Search", message: "Please enter a course title!")
            } else {
                let coursesRef = Database.database().reference(withPath: "courses")
                
             DispatchQueue.global(qos: .userInitiated).async{
                coursesRef.child(search).observe(.value, with: { snapshot in
                    if(snapshot.exists()){
                        self.users.removeAll()
                        self.swipeableCardView.reloadData()
                    }
                    for child in snapshot.children {
                        if let snapshot = child as? DataSnapshot {
                            print(snapshot.key)
                            self.ref.child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
                                if (snapshot.value as? [String: AnyObject]) != nil {
                                    if let childUser = User(snapshot: snapshot) {
                                        var inView = false
                                        for user in self.users {
                                            if(user.uid == childUser.uid){
                                                inView = true
                                            }
                                        }
                                        if !inView {
                                            var alreadySwiped = false
                                            let swipesRef = Database.database().reference(withPath: "swipes")
                                            let otherUserSwipesRef = swipesRef.child(childUser.uid)
                                            print( otherUserSwipesRef.child(self.currentUID))
                                            otherUserSwipesRef.child(self.currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
                                                    if (snapshot.value as? [String: AnyObject]) != nil {
                                                        alreadySwiped = true
                                                    }
                                                
                                                    //update the matching view with the cards of users that they haven't swiped right on
                                                    if self.currentUser != childUser.email && !alreadySwiped{
                                                        self.users.append(childUser)
                                                        self.swipeableCardView.reloadData()
                                                    }
                                                })
                                            }
                                        }
                                    
                                    }
                                })
                            }
                        }
                    })
                    DispatchQueue.main.async{
                        self.swipeableCardView.reloadData()
                    }
                }
            }
        }
    }
}




// MARK: - SwipeableCardViewDataSource

extension MatchingViewController {
    
    func numberOfCards() -> Int {
        return users.count
    }
    
    func card(forItemAtIndex index: Int) -> SwipeableCardViewCard {
        let otherUser = users[index]
        let cardView = SampleSwipeableCard()
        cardView.viewModel = otherUser
        return cardView
    }
    
    func viewForEmptyCards() -> UIView? {
        return nil
    }
}

extension MatchingViewController {
}

