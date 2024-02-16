//
//  StartChat.swift
//  Chat Clone
//
//  Created by Mohammed on 15/01/2024.
//

import Foundation
import Firebase


func restartChat(chatRoomId: String, memberIds: [String]) {
    
    //Download users using memberIds
    
    FUserListener.shared.downloadUsersFromFirestore(withIds: memberIds) { (allUsers) in
        if allUsers.count > 0 {
            craetChatRooms(chatRoomId: chatRoomId, users: allUsers)
        }
        
    }

    
}

func startChat (sendre: User, reciver: User) -> String {
    var chatRoomId = ""
    
    let value = sendre.id.compare(reciver.id).rawValue
    
    chatRoomId = value < 0 ? (sendre.id + reciver.id) : (reciver.id + sendre.id)
    
    craetChatRooms(chatRoomId: chatRoomId, users: [sendre, reciver])
    
    return chatRoomId
}

func craetChatRooms(chatRoomId: String, users: [User]) {
    // if user has already chatroom we will not creat
    
    var usersToCreateChatsFor:[String]
    usersToCreateChatsFor = []
    
    for user in users {
        usersToCreateChatsFor.append(user.id)
    }
    
    firestoreRefrance(.Chat).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (querysnapshot, error) in
        
        guard let snapshot = querysnapshot else { return }
        
        if !snapshot.isEmpty {
            
            for chatData in snapshot.documents {
                let currentChat = chatData.data() as Dictionary
                
                if let currentUserId = currentChat[kSENDREID] {
                    if usersToCreateChatsFor.contains(currentUserId as! String) {
                        
                        usersToCreateChatsFor.remove(at: usersToCreateChatsFor.firstIndex(of: currentUserId as! String)!)
                    }
                }
            }
        }
        
        for userId in usersToCreateChatsFor {
            
            let senderUser = userId == User.currentId ? User.currentUser! : getRecieverFrom(users: users)
            
            let receiverUser = userId == User.currentId ? getRecieverFrom(users: users) : User.currentUser!
            
            let chatRoomObject = ChatRoom(id: UUID().uuidString, chatRoomId: chatRoomId, senderId: senderUser.id, sendreName: senderUser.username, recieverId: receiverUser.id, recieverName: receiverUser.username, date: Date(), memberIds: [senderUser.id, receiverUser.id], lastMessage: "", unreadCounter: 0, avatarLink: receiverUser.avatarLink)
            
                //TODO: Save chat to firestore
            
            FChatRoomListener.shared.saveChatRoom(chatRoomObject)
            
        }
    
    
    
    
    }
    
}


func getRecieverFrom(users: [User]) -> User {
    
    var allUsers = users
    
    allUsers.remove(at: allUsers.firstIndex(of: User.currentUser!)!)
    
    return allUsers.first!
}
