//
//  MessageDisplayDelegate.swift
//  Chat Clone
//
//  Created by Mohammed on 17/01/2024.
//

import Foundation
import MessageKit
import UIKit

extension MSGViewController: MessagesDisplayDelegate {
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        return .label
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        let bubbleColorOutgoing = UIColor(named: "ColorOutgoingBublle")
        let bubbleColorIncoming = UIColor(named: "ColorincomingBubble")
        
        return isFromCurrentSender(message: message) ? bubbleColorOutgoing as! UIColor : bubbleColorIncoming as! UIColor
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        
        return .bubbleTail(tail, .curved)
    }
}

extension ChannelMSGViewController: MessagesDisplayDelegate {
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        return .label
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        let bubbleColorOutgoing = UIColor(named: "ColorOutgoingBublle")
        let bubbleColorIncoming = UIColor(named: "ColorincomingBubble")
        
        return isFromCurrentSender(message: message) ? bubbleColorOutgoing as! UIColor : bubbleColorIncoming as! UIColor
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        
        return .bubbleTail(tail, .curved)
    }
}
