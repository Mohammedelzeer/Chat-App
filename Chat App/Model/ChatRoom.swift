//
//  ChatRoom.swift
//  Chat Clone
//
//  Created by Mohammed on 15/01/2024.
//

import Foundation
import FirebaseFirestoreSwift
//import Firebase


//chatroom:codable
struct ChatRoom: Encodable, Decodable {
    
    var id = ""
    var chatRoomId = ""
    var senderId = ""
    var sendreName = ""
    var recieverId = ""
    var recieverName = ""
     
     
    @ServerTimestamp var date = Date()
    var memberIds = [""]
    var lastMessage = ""
    var unreadCounter = 0
    var avatarLink = ""
    
    
}




