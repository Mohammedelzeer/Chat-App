//
//  FMessageListener.swift
//  Chat Clone
//
//  Created by Mohammed on 18/01/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import SwiftUI

class FMessageListener {
    
    static let shared = FMessageListener()
    var newMessageListener: ListenerRegistration!
    var updatedMessageListener: ListenerRegistration!

    
    private init () {}
    
    func addMessage (_ message: LocalMessage, memberId: String) {
        do {
            try
            firestoreRefrance(.Message).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)

        } catch {
            print("error saving message to firestore", error.localizedDescription)
        }
    }
    
    //MARK:- send channel
    
    func addChannelMessage (_ message: LocalMessage, channel: Channel) {
        do {
            try
            firestoreRefrance(.Message).document(channel.id).collection(channel.id).document(message.id).setData(from: message)

        } catch {
            print("error saving message to firestore", error.localizedDescription)
        }
    }

    
    func checkForOldMessage(_ documentId: String, collectionId: String) {
        
        firestoreRefrance(.Message).document(documentId).collection(collectionId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {return}
            
            var oldMessages = documents.compactMap { (querySnapshot) -> LocalMessage? in
                return try? querySnapshot.data(as: LocalMessage.self)
            }
            
            oldMessages.sort(by: {$0.date < $1.date})
            for message in oldMessages {
                RealmManger.shared.save(message)
            }
        }
    }
    
    func listenForNewMessages(_ documentId: String, collectionId: String, lastMessageDate: Date) {
        newMessageListener = firestoreRefrance(.Message).document(documentId).collection(collectionId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (querySnapshot, error) in
            guard let snapshot = querySnapshot else {return}
            for change in snapshot.documentChanges {
                if change.type == .added {
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    switch result {
                    case .success(let messageObject):
                        if let message = messageObject {
                            if message.senderId != User.currentId {
                                RealmManger.shared.save(message)
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        })
    }
    
    //MARK:- Ubdate Message Status
    
    func updateMessageStatus(_ message: LocalMessage, userId: String) {
        
        let values = [kSTATUS: kREAD, kREADDATE: Date()] as [String: Any]
        
        firestoreRefrance(.Message).document(userId).collection(message.chatRoomId).document(message.id).updateData(values)
    }
    
    //MARK:- Listen forRead status update
    
    func listenForReadStatus (_ documentId: String, collectionId: String, completion: @escaping(_ updatedMessage: LocalMessage)->Void) {
        
        updatedMessageListener =
        firestoreRefrance(.Message).document(documentId).collection(collectionId).addSnapshotListener({ (querySnapshot, error)  in
            
            guard let snapshot = querySnapshot else {return}
            
            for change in snapshot.documentChanges {
                if change.type == .modified {
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        if let message = messageObject {
                            completion(message)
                        }
                            
                            
                    case .failure(let error):
                                print("Error decoding", error.localizedDescription)
                    
                    }
                }
            }
        })
    }
    
    
    
    
    
    
    
    
    func removeNewMessageListener() {
        self.newMessageListener.remove()
        if updatedMessageListener != nil {
            self.updatedMessageListener.remove()
        }
       
    }
}
