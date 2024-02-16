//
//  FChatRoomListener.swift
//  Chat Clone
//
//  Created by Mohammed on 16/01/2024.
//

import Foundation
import Firebase

class FChatRoomListener {
    
    static let shared = FChatRoomListener()
    
    private init () {}
    
    func saveChatRoom (_ chatRoom: ChatRoom) {
        
        do {
            try firestoreRefrance(.Chat).document(chatRoom.id).setData(from: chatRoom)
            
        }catch {
            print("No able to save documents", error.localizedDescription)
        }
        
        
    }
    
    //Mark:- Delete function
    
    func deleteChatRoom (_ chatRoom: ChatRoom) {
        firestoreRefrance(.Chat).document(chatRoom.id).delete()
    }
    
    //Mark:- Download all chat rooms
    
    func downloadChatRooms (completion: @escaping(_ allFBChatRooms: [ChatRoom])->Void) {
        firestoreRefrance(.Chat).whereField(kSENDREID, isEqualTo: User.currentId).addSnapshotListener{ (snapshot, error) in
            
            var chatRooms: [ChatRoom] = []
            guard let documents = snapshot?.documents else {
                print("no documents found")
                return
            }
            let allFBChatRooms = documents.compactMap { (snapshot) in
                return try? snapshot.data (as: ChatRoom.self)
            }
            for chatRoom in allFBChatRooms {
                if chatRoom.lastMessage != "" {
                    chatRooms.append(chatRoom)
                }
            }
            chatRooms.sort (by: {$0.date! > $1.date!})
            completion(chatRooms)
    }
}
    
    //MARK:- reset unread counter
    
    func clearUnreadCounter(chatRoom: ChatRoom) {
        
        var newChatRoom = chatRoom
        newChatRoom.unreadCounter = 0
        self.saveChatRoom(newChatRoom)
    }
    
    func clearUnreadCounterUsingChatRoomId(chatRoomId: String) {
        
        firestoreRefrance(.Chat).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDREID, isEqualTo: User.currentId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {return}
            
            let allChatRooms = documents.compactMap { (querySnapshot) -> ChatRoom? in
                return try? querySnapshot.data(as: ChatRoom.self)
                
                
            }
            if allChatRooms.count > 0 {
                self.clearUnreadCounter(chatRoom: allChatRooms.first!)
            }
        }
    }
    
    //MARK:- Update ChatRoom with New Message
    
    private func ubdateChatRoomWithNewMessage(chatRoom: ChatRoom, lastMessage: String) {
        var tempChatRoom = chatRoom
        
        if tempChatRoom.senderId != User.currentId {
            tempChatRoom.unreadCounter += 1
        }
        tempChatRoom.lastMessage = lastMessage
        tempChatRoom.date = Date()
        self.saveChatRoom(tempChatRoom)
    }
    
    func updateChatRooms(chatRoomId: String, lastMessage: String) {
        
        firestoreRefrance(.Chat).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {return}
            
            let allChatRooms = documents.compactMap { (querySnapshot) -> ChatRoom? in
                return try? querySnapshot.data(as: ChatRoom.self)
            }
            
            for chatRoom in allChatRooms{
                self.ubdateChatRoomWithNewMessage(chatRoom: chatRoom, lastMessage: lastMessage)
            }
            
        }
    }
    
    
}

