//
//  LoginController+handlers.swift
//  ChatApp
//
//  Created by Daniel Collazo on 5/8/17.
//  Copyright © 2017 Daniel Collazo. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        
        // Create Firebase user account
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (FIRUser, error) in
            if error != nil {
                print(error ?? "")
                return
            }
            
            guard let uid = FIRUser?.uid else {
                return
            }
            
            // Successfully authenticated user
            let imageName = NSUUID().uuidString
            // Store/upload users image to firebase server
            let storageRef = FIRStorage.storage().reference().child("\(imageName).png")
            
            // Compress file so that size is smaller and loads faster
            //if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1)
            // this is the same line of code but safer because you are no longer wrapping a possible nil value/object
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                
            // These files were being uploaded as PNG and not compressed
//            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print(error ?? "")
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                        self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                    }
                    
                })
            }
            
        })
        print(123)
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference()
        
        // Create reference to user node in Firebase
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err ?? "")
                return
            }
            
//            self.messagesController?.fetchUserAndSetupNavBarTitle() 
            // eliminate having to call the function above
//            self.messagesController?.navigationItem.title = values["name"] as? String
            let user = User()
            user.setValuesForKeys(values)
            // This setter potentially crashes if keys don't match
            self.messagesController?.setupNavBarWithUser(user: user)
            
            // Dismiss Login/Register VC
            self.dismiss(animated: true, completion: nil)
        })
    }

    
    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled picker")
        dismiss(animated: true, completion: nil)
    }
    
}
