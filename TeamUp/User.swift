//
//  User.swift
//  TeamUp
//
//  Created by STSAdmin on 11/25/18.
//  Copyright © 2018 STSAdmin. All rights reserved.
//

import Foundation
import Firebase

struct User {
    
    
    let uid: String
    var firstName: String
    var lastName: String
    var universityName: String
    var phoneNumber: String
    let email: String
    var year: String
    var image: String
    var skills: String
    var color: UIColor
    var availability: String
    var coursesTaken: String
    var location: String
    var description: String
    var wantedCourses: String
    
    
    //    init(authData: Firebase.User) {
    //        uid = authData.uid
    //        email = authData.email!
    //    }
    
    init(uid: String = "", firstName: String = "", lastName: String = "", phoneNumber: String = "", universityName: String = "", email: String = "", year: String = "", color: UIColor = UIColor.white, image: String = "", availability: String = "", courses: String = "", location: String = "", skills: String = "", description: String = "", wantedCourses: String = "") {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.universityName = universityName
        self.email = email
        self.year = year
        self.description = description
        self.image = image
        self.color = randomColor()
        self.availability = availability
        self.coursesTaken = courses
        self.location = location
        self.skills = skills
        self.wantedCourses = wantedCourses
    }
    
    init(authData: Firebase.User) {
        self.init(uid: authData.uid)
    }
    
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject]
            //            let name = value["uid"] as? String
            //let addedByUser = value["addedByUser"] as? String,
            //let completed = value["completed"] as? Bool
            else {
                return nil
        }
        
        //self.init(firstName: value["firstName"] as! String, email: value["email"] as! String)
        self.uid = value["uid"] as! String
        self.firstName = value["firstName"] as! String
        self.lastName = value["lastName"] as! String
        self.phoneNumber=value["phoneNumber"] as! String
        self.universityName = value["universityName"] as! String
        self.email = value["email"] as! String
        self.year = value["year"] as! String
        self.description = value["description"] as! String
        if let imageURL = value["image"] {
            self.image =  imageURL as! String
        } else {
            self.image = ""
        }
        self.color = randomColor()
        self.availability = value["availability"] as! String
        self.coursesTaken = value["courses"] as! String
        self.location = value["location"] as! String
        self.skills = value["skills"] as! String
        self.wantedCourses = value["wantedCourses"] as! String
    }
    
    func toAnyObject() -> Any {
        return [
            "uid": uid,
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "universityName": universityName,
            "description": description,
            "email":email,
            "year": year,
            "availability": availability,
            "courses": coursesTaken,
            "image": image,
            "location": location,
            "skills": skills,
            "wantedCourses": wantedCourses
        ]
    }
}

// Getting a random CGFLoat: https://stackoverflow.com/questions/25050309/swift-random-float-between-0-and-1
// Checking lightness of colors generated for the background: https://stackoverflow.com/questions/23377028/how-to-ensure-that-random-uicolors-are-visible-on-a-white-background-in-ios
// 0 is for black, 1 is for white. We choose a threshold for the lightness
func randomColor() -> UIColor {
    while (true) {
        let red: CGFloat =  CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let blue: CGFloat = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let green: CGFloat = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let gray: CGFloat = 0.299 * red + 0.587 * green + 0.114 * blue;
        
        if (gray > 0.4) {
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}
