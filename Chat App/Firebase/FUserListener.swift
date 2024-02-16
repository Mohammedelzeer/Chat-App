//
//  FUserListener.swift
//  Chat Clone
//
//  Created by Mohammed on 07/01/2024.
//

import Foundation
import Firebase


class FUserListener {
    static let shared = FUserListener()
    
    private init () {}
    
    //MARK:- Login
    
    func loginUserWith(email: String, password: String, completion: @escaping(_ error: Error?,_ isEmailVerified: Bool) ->Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResults, error) in
            if error == nil && authResults!.user.isEmailVerified {
                completion (error, true)
                self.downloadUserFromFireStore(userId: authResults!.user.uid)
                
            } else {
                completion(error, false)
            }
    }
}

    //MARK:- Logout
    
    
    func logoutCurrentUser(completion: @escaping (_ error: Error?)-> Void) {
        
        do {
            try Auth.auth().signOut()
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)
            
        } catch let error as NSError {
            completion(error)
            
        }
    }
    
    
    
    
    
    
    
    
    //MARK:- Register
    
    
    func registerUserWith (email: String, password: String, completion: @escaping (_ error: Error?) ->Void)
       {
        Auth.auth().createUser(withEmail: email, password: password) { (authResults, error) in
            completion(error)
            if error == nil {
                authResults!.user.sendEmailVerification { (error) in
                    
                    completion(error)
                    
                    
                }
            }
            
            if authResults?.user != nil {
                let user = User(id: authResults!.user.uid, username: email, email: email, pushId: "", avatarLink: "", status: "Hey , I am using Chat Clone")
                
                self.saveUserToFireStore(user)
                saveUserLocally(user)
            }
        }
    }
    
    //MARK:- Resend link verfication function
    
    func resendVerficationEmailWith(email: String, completion: @escaping (_ error: Error?)->Void) {
        Auth.auth().currentUser?.reload(completion: { (error) in
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
              completion(error)
        })
    })
    
    
    
    }
    
    //MARK:- Reset password
    
    func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    
    
    
    
    
    
    //MARK:- Download user From FireStore
    
     func saveUserToFireStore(_ user: User) {
        
        do {
            
        try firestoreRefrance(.User).document(user.id).setData(from: user)
        } catch {
            print (error.localizedDescription)
        }
    }
    
    private func downloadUserFromFireStore (userId: String) {
        
        firestoreRefrance(.User).document(userId).getDocument { (document, error) in
            guard let userDocument = document else {
                print("no data found")
                return
            }
            let result = Result {
                try? userDocument.data(as: User.self)
            }
            switch result {
            case .success(let userObject):
                if let user = userObject {
                    saveUserLocally(user)
            
                } else {
                    print("Document does not exist")
                }
            case .failure(let error):
                print("error decoding user", error.localizedDescription)
            }
        }
    }
    
    //MARK:- Download users using IDs
    func downloadUsersFromFirestore(withIds: [String], completion: @escaping(_ allUsers: [User])->Void) {
        
        var count = 0
        var userArray: [User] = []
        
        for userId in withIds {
            firestoreRefrance(.User).document(userId).getDocument { (querySnapshot, error) in
                guard let document = querySnapshot else {
                    return
                }
                let user = try? document.data(as: User.self)
                userArray.append(user!)
                count+=1
                if count == withIds.count {
                    completion (userArray)
                }
                
            }
        }
    }
    
    
    //MARK:- Download all users
    func downloadAllUsersFromFirestore(completion: @escaping (_ allUsers: [User])->Void) {
        
        var users: [User] = []
        firestoreRefrance(.User).getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("no documents found")
                return
            }
            
            let allUsers = documents.compactMap { (snapshot) -> User? in
                return try? snapshot.data(as: User.self)
         }
            for user in allUsers {
                if User.currentId != user.id {
                    users.append(user)
                }
            }
            
            completion(users)
     }
  }
    
}

            
            
            
            
            
            
            
            
            
            
            
            
            
        
