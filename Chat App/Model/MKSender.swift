//
//  MKSender.swift
//  Chat Clone
//
//  Created by Mohammed on 17/01/2024.
//

import Foundation
import MessageKit
import UIKit

struct MKSender: SenderType, Equatable {
    
    var senderId: String
    
    var displayName: String
}
