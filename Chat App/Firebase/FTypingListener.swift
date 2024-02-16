//
//  FTypingListener.swift
//  Chat Clone
//
//  Created by Mohammed on 22/01/2024.
//

import Foundation
import Firebase

class FTypingListener {
    
    static let shared = FTypingListener()
    
    var typingListener: ListenerRegistration!
    
    private init () {}
    
    
    func createTypingObserver (chatRoomId: String, completion: @escaping(_ isTyping: Bool)->Void) {
        
        typingListener = firestoreRefrance(.Typing).document(chatRoomId).addSnapshotListener({ (documentSnapshot, error)  in
            
            guard let snapshot = documentSnapshot else {return}
            
            if snapshot.exists {
                for data in snapshot.data()! {
                    if data.key != User.currentId {
                        completion(data.value as! Bool)
                    }
                }
            } else {
                completion(false)
                firestoreRefrance(.Typing).document(chatRoomId).setData([User.currentId: false])
            }
        })
    }
    
    class func saveTypingCounter(typing: Bool, chatRoomId: String) {
        firestoreRefrance(.Typing).document(chatRoomId).updateData([User.currentId: typing])
    }
    
    func removeTypingListener() {
        self.typingListener.remove()
    }
}
