//
//  DetailsViewController.swift
//  TeamUp
//
//  Created by STSAdmin on 11/25/18.
//  Copyright © 2018 STSAdmin. All rights reserved.
//


import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class DetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearChoices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        year = yearChoices[row]
    }
    
    // NOT SURE IF THIS FUNCTION IS NEEDED. SEE IF CAN DISPOSE IF WORKS
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return yearChoices[row]
    }
    
    var user: User!
    let ref = Database.database().reference(withPath: "users")
    var year: String!
    let yearChoices = ["Freshman", "Sophomore", "Junior", "Senior", "Grad Student", "Not Applicable"]
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var yearPicker: UIPickerView!
    @IBOutlet var yearTextField: UITextField!
    
    @IBOutlet var coursesWantedTextField: UITextField!
    @IBOutlet var coursesTakenTextField: UITextView!
    @IBOutlet var skillsTextField: UITextView!
    @IBOutlet var availabilityTextField: UITextView!
    @IBOutlet var descriptionTextField: UITextView!
    
    
    @IBAction func editButton(_ sender: Any) {
        changeToTrue()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if firstNameTextField.text == nil || firstNameTextField.text == "" {
            // throw alert: first name cannot be empty
            createAlert(title: "Empty First Name", message: "\"First Name\" cannot be empty!")
            
            // do not save if this error is encountered
            return
        }
        
        // need to save the details, both in the database and our current structure
        if firstNameTextField.text != user.firstName {
            // errors checked above
            user.firstName = firstNameTextField.text!
            self.ref.child("\(user.uid)/firstName").setValue(user.firstName)
        }
        
        if lastNameTextField.text != user.lastName {
            // no error on empty text field
            user.lastName = lastNameTextField.text!
            self.ref.child("\(user.uid)/lastName").setValue(user.lastName)
        }
        
        if year != user.year {
            // no error on empty text field
            user.year = year
            self.ref.child("\(user.uid)/year").setValue(user.year)
            yearTextField.text = user.year
        }
        
        if coursesWantedTextField.text != user.wantedCourses {
            user.wantedCourses = coursesWantedTextField.text!
            self.ref.child("\(user.uid)/wantedCourses").setValue(user.wantedCourses)
        let coursesRef = Database.database().reference(withPath: "courses")
        let wantedCourses = self.coursesWantedTextField.text!.components(separatedBy: " ")
        for course in wantedCourses {
            coursesRef.child(course).child(user.uid).updateChildValues([
                "wanted": "true"
                ])
        }
        }
    
        

        
        
        
        if coursesTakenTextField.text != user.coursesTaken {
            // no error on empty text field
            user.firstName = firstNameTextField.text!
            self.ref.child("\(user.uid)/firstName").setValue(user.firstName)
        }
        
        if skillsTextField.text != user.skills {
            // no error on empty text field
            user.skills = skillsTextField.text!
            self.ref.child("\(user.uid)/skills").setValue(user.skills)
        }
        
        if availabilityTextField.text != user.availability {
            // no error on empty text field
            user.availability = availabilityTextField.text!
            self.ref.child("\(user.uid)/availability").setValue(user.availability)
        }
        
        if descriptionTextField.text != user.description {
            // no error on empty text field
            user.description = descriptionTextField.text!
            self.ref.child("\(user.uid)/description").setValue(user.description)
        }
        
        // path never changes, image at that path does
        uploadImageToFirebase()
        
        // exit editing mode
        changeToFalse()
    }
    
    //learned how to do this at: https://www.youtube.com/watch?v=4EAGIiu7SFU
    func createAlert(title:String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func changeToTrue() {
        firstNameTextField.isUserInteractionEnabled = true
        lastNameTextField.isUserInteractionEnabled = true
        yearPicker.isUserInteractionEnabled = true
        coursesTakenTextField.isUserInteractionEnabled = true
        skillsTextField.isUserInteractionEnabled = true
        availabilityTextField.isUserInteractionEnabled = true
        descriptionTextField.isUserInteractionEnabled = true
        profileImageView.isUserInteractionEnabled = true
        coursesWantedTextField.isUserInteractionEnabled = true
        yearTextField.isHidden = true;
        yearPicker.isHidden = false;
    }
    
    func changeToFalse() {
        firstNameTextField.isUserInteractionEnabled = false
        lastNameTextField.isUserInteractionEnabled = false
        yearPicker.isUserInteractionEnabled = false
        coursesTakenTextField.isUserInteractionEnabled = false
        skillsTextField.isUserInteractionEnabled = false
        availabilityTextField.isUserInteractionEnabled = false
        descriptionTextField.isUserInteractionEnabled = false
        profileImageView.isUserInteractionEnabled = false
        coursesWantedTextField.isUserInteractionEnabled = false
        yearTextField.isHidden = false;
        yearPicker.isHidden = true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // profile image view things done here
        // setting bg color
        profileImageView.backgroundColor = UIColor.gray;
        // add tap gesture to the imageView
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnImageView)))
        
        // if user is logged in, show their details
        if Auth.auth().currentUser != nil {
            // email will always be a string
            let email: String = (Auth.auth().currentUser?.email)!
            
            // split email by @, the first part is the username
//            let username: String = String(email.split(separator: "@")[0])
            
            var currentUID = ""
            
            ref.queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .childAdded, with: { (snapshot) in
                //print("\(snapshot.key)")
                currentUID="\(snapshot.key)"
                
                self.ref.child(currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value, make a user object
                    // initializer in User.swift takes care of it
                    self.user = User(snapshot: snapshot)
                    self.year = self.user.year
                    
                    // Put in the user data to all the text fields, function below
                    self.putDataInTextFields()
                }) { (error) in
                    // default method of dealing with error, by Firebase docs
                    print(error.localizedDescription)
                }
            
            })
            
            // get the user's details
//            ref.child(currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
//                // Get user value, make a user object
//                // initializer in User.swift takes care of it
//                self.user = User(snapshot: snapshot)
//                self.year = self.user.year
//
//                // Put in the user data to all the text fields, function below
//                self.putDataInTextFields()
//            }) { (error) in
//                // default method of dealing with error, by Firebase docs
//                print(error.localizedDescription)
//            }
        } else {
            // do nothing
        }
    }
    
    func putDataInTextFields() {
        // all variables have atleast a default value, no need for checking
        
        firstNameTextField.text = user.firstName
        lastNameTextField.text = user.lastName
        yearTextField.text = user.year
        coursesTakenTextField.text = user.coursesTaken
        skillsTextField.text = user.skills
        availabilityTextField.text = user.availability
        descriptionTextField.text = user.description
        coursesWantedTextField.text = user.wantedCourses
        
        // sets image view with profile picture
        getProfilePic()
    }
    
    func getProfilePic() {
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        // Reference to an image file in Firebase Storage
        let reference = storageRef.child(user.image)
        
        // Download in memory with a maximum allowed size of 4MB (4 * 1024 * 1024 bytes)
        reference.getData(maxSize: 4 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error)
                self.profileImageView.image = #imageLiteral(resourceName: "person-tab")
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.profileImageView.image = image
                // print(image)
                return
            }
        }
    }
    
    @objc func handleTapOnImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker,animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var pickedImage : UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            pickedImage = editedImage
        }
        else if let ogImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            pickedImage = ogImage
        }
        if let pImage = pickedImage{
            profileImageView.image = pImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // reference: https://stackoverflow.com/questions/44060518/uploading-image-to-firebase-storage-and-database
    // reference: https://www.youtube.com/watch?v=b1vrjt7Nvb0
    // reference: https://firebase.google.com/docs/storage/ios/upload-files
    func uploadImageToFirebase() {
        // create reference
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("images")
        
        // create exact file reference with username
        let fileName = self.user.uid + ".jpg"
        let spaceRef = imagesRef.child(fileName)
        
        // get the full path to return later
        let _ = spaceRef.fullPath;
        
        // get image from the image view if not nil
        if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
            
            // Create the file metadata
            //let metadata = StorageMetadata()
            //metadata.contentType = "image/png"
            
            // upload image at this path
            _ = spaceRef.putData(uploadData, metadata: nil) { (metadata, error) in
                guard metadata != nil else {
                    // Uh-oh, an error occurred!
                    return
                }
            }
        }
        
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
