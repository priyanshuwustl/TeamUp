//
//  AccountCreationViewController.swift
//  TeamUp
//
//  Created by Jessika Baral on 11/18/18.
//

//learned picker view usage from: https://www.youtube.com/watch?v=tGr7qsKGkzY
//learned how to store information in firebase from app from: https://www.raywenderlich.com/3-firebase-tutorial-getting-started
//learned how to store an image into firebase from:

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class AccountCreationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var ref = Database.database().reference(withPath: "users")
    var graduationYear = "Freshman"
    
    //necessary buttons for creating an account
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet var phoneNumber: UITextField!
    @IBOutlet weak var universityName: UITextField!
    
    //change grad year to a drop down with an NA
    //freshman -- senior, grad student, NA
    @IBOutlet weak var graduationYearPicker: UIPickerView!
    
    
    @IBOutlet var skills: UITextField!
    
    @IBOutlet var wantedCourses: UITextField!
    @IBOutlet var coursesTaken: UITextField!
    
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet var availability: UITextField!
    @IBOutlet var location: UITextField!
    
    @IBOutlet var username: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    
    
    let yearChoices = ["Freshman", "Sophomore", "Junior", "Senior", "Grad Student", "Not Applicable"]
    
    func somethingIsEmpty() -> Bool {
        var isEmpty = false
        if firstName.text == "" || lastName.text == "" || phoneNumber.text == "" || descriptionTextField.text == "" || skills.text == "" || coursesTaken.text == "" || availability.text == "" || location.text == "" || username.text == "" || universityName.text == "" || emailTextField.text == "" || passwordTextField.text == "" || confirmPassword.text == "" || wantedCourses.text == ""{
            isEmpty = true
        }
        
        return isEmpty
    }
    
    @IBAction func createAccountButton(_ sender: Any) {
        //redirect to the home page
        //link the button to the original view controller
        
//        let test="hello.hello"
//
//        if test.contains("."){
//            print("test worked!!!!!!!")
//        }
        
        if somethingIsEmpty() {
            self.createAlert(title: "Incomplete", message: "Please fill out all the boxes. Feel free to write N/A for those that you wish to leave blank!")
            
        } else {
            if (username.text?.contains("."))! || (username.text?.contains("#"))! || (username.text?.contains("$"))! || (username.text?.contains("["))! || (username.text?.contains("]"))! || (username.text?.contains(" "))! || (username.text?.contains("@"))! || (username.text?.contains("!"))!   {
                print("test worked!!!!!!!")
                self.createAlert(title: "Invalid Username", message: "Username cannot contain special characters or spaces.")
            }
            else if phoneNumWrong() {
                createAlert(title: "Invalid Phone Number", message: "Phone number cannot contain anything but numbers! It must also be 10 digits long. Please add the area code.")
                phoneNumber.text = nil
            } else {
                ref.child(username.text!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if (snapshot.value as? [String: AnyObject]) != nil {
                        self.createAlert(title: "Username Already Taken", message: "This username is already taken. Please try again.")
                    }
//                    else if self.username.text!.contains("."){
//                        print("contains!!!!!!!")
//                        self.createAlert(title: "Invalid Username", message: "Username cannot contain special characters or spaces.")
//                    }
                    else{
                        Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (authResult, error) in
                            //                guard let user = authResult?.user else { return }
                            if error == nil {
                                
                                //Auth.auth().setUserId(username.text)!
                                
                                Auth.auth().signIn(withEmail: self.emailTextField.text!,
                                                   password: self.passwordTextField.text!)
                                
                                let imagePath = self.uploadImageToFirebase()
                                let user = User(uid: self.username.text!,
                                                firstName: self.firstName.text!,
                                                lastName: self.lastName.text!,
                                                phoneNumber: self.phoneNumber.text!,
                                                universityName: self.universityName.text!,
                                                email: self.emailTextField.text!,
                                                year: self.graduationYear,
                                                color: UIColor.white,
                                                image: imagePath,
                                                availability: self.availability.text!,
                                                courses: self.coursesTaken.text!,
                                                location: self.location.text!,
                                                skills: self.skills.text!,
                                                description: self.descriptionTextField.text!,
                                                wantedCourses: self.wantedCourses.text!)
                                
                                let userRef = self.ref.child(self.username.text!)
                                
                                userRef.setValue(user.toAnyObject())
                                
//                                let wantedCourses = self.wantedCourses.text!.components(separatedBy: " ")
//                                let wantedCoursesRef = userRef.child("wantedCourses")
//                                for course in wantedCourses {
//                                    wantedCoursesRef.child(course).updateChildValues([
//                                            "wanted": course
//                                        ])
//                                }
                                
                                let coursesRef = Database.database().reference(withPath: "courses")
                                let wantedCourses = self.wantedCourses.text!.components(separatedBy: " ")
                                for course in wantedCourses {
                                    coursesRef.child(course).child(self.username.text!).updateChildValues([
                                            "wanted": "true"
                                        ])
                                }
                                
                                self.performSegue(withIdentifier: "creationToHome", sender: nil)
                            }
                            else{
                                self.createAlert(title: "Error", message: (error?.localizedDescription)!)
                            }
                        }
                    }
                })
                if passwordTextField.text!.count < 7 {
                    createAlert(title: "Password Is Too Short", message: "Please make sure your password is 7 or more characters long!")
                    passwordTextField.text = nil
                    confirmPassword.text = nil
                } else {
                    if checkMatch() {
                        //segue to new page
                        //self.performSegue(withIdentifier: "creationToHome", sender: nil)
                        //print("test")
                    } else {
                        //call the popup error that says that the passwords don't match
                        //reset the password boxes to blank
                        createAlert(title: "Password Mismatch", message: "The two passwords that you entered do not match! Please try again.")
                        passwordTextField.text = nil
                        confirmPassword.text = nil
                    }
                }
            }
        }
    }
    
    



    func phoneNumWrong() -> Bool {
        let inputtedString = phoneNumber.text!
        var wrongNum = false
        if(inputtedString.count != 10) {
            wrongNum = true
        } else {
            if inputtedString.rangeOfCharacter(from: NSCharacterSet.decimalDigits.inverted) != nil {
                wrongNum = true
            }
        }
        return wrongNum
        //return inputtedString.rangeOfCharacter(from: NSCharacterSet.decimalDigits.inverted) != nil
    }
    
//    func firebaseUploadPath() -> String {
//        let usernameStr = username.text {
//            return "images/" + usernameStr
//        }; else do {
//            return "images/"
//        }
//    }
    
    // reference: https://stackoverflow.com/questions/44060518/uploading-image-to-firebase-storage-and-database
    // reference: https://www.youtube.com/watch?v=b1vrjt7Nvb0
    // reference: https://firebase.google.com/docs/storage/ios/upload-files
    func uploadImageToFirebase() -> String {
        // create reference
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("images")

        // create exact file reference with username
        let fileName = self.username.text! + ".jpg"
        let spaceRef = imagesRef.child(fileName)

        // get the full path to return later
        let path = spaceRef.fullPath;
        
        // placeholder image
        if self.profilePic.image == nil {
            self.profilePic.image = #imageLiteral(resourceName: "person-tab")
        }
        
        // get image from the image view if not nil
        if let uploadData = UIImagePNGRepresentation(self.profilePic.image!) {

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

        return path
    }
    
    @IBAction func clearInformation(_ sender: Any) {
        firstName.text = nil
        lastName.text = nil
        phoneNumber.text = nil
        descriptionTextField.text = nil
        skills.text = nil
        coursesTaken.text = nil
        availability.text = nil
        location.text = nil
        profilePic.image = nil
        username.text = nil
        universityName.text = nil
        emailTextField.text = nil
        passwordTextField.text = nil
        confirmPassword.text = nil
        wantedCourses.text = nil
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return yearChoices[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearChoices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        graduationYear = yearChoices[row]
    }
    
    func checkMatch() -> Bool {
        if passwordTextField.text == confirmPassword.text {
            return true
        } else {
            return false
        }
    }
    
    
    //learned how to do this at: https://www.youtube.com/watch?v=4EAGIiu7SFU
    func createAlert(title:String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet var profilePic: UIImageView!
    
    @IBAction func uploadImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker,animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var pickedImage : UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            pickedImage = editedImage
        }
        else if let ogImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            pickedImage = ogImage
        }
        if let pImage = pickedImage{
            profilePic.image = pImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        confirmPassword.isSecureTextEntry = true
        
        // Do any additional setup after loading the view.
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


