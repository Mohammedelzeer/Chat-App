//
//  Channel.swift
//  Chat Clone
//
//  Created by Mohammed on 03/02/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Channel: Codable {
    
    var id = ""
    var name = ""
    var adminId = ""
    var memberIds = [""]
    var avatarLink = ""
    var aboutChannel = ""
    @ServerTimestamp var createDate = Date()
    @ServerTimestamp var lastMessageDate = Date()
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case adminId
        case memberIds
        case avatarLink
        case aboutChannel
        case createDate
        case lastMessageDate = "date"
    }
}
