//
//  InputBarAccessoryViewDelagate.swift
//  Chat Clone
//
//  Created by Mohammed on 17/01/2024.
//

import Foundation
import InputBarAccessoryView

extension MSGViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        print("Typing", text)
        
        updateMicButtonStatus(show: text == "")
        
        if text != "" {
            startTypingIndicator()
        }
        
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        send(text: text, photo: nil, video: nil, audio: nil, location: nil)
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
    
}

extension ChannelMSGViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        print("Typing", text)
        
        updateMicButtonStatus(show: text == "")
        
//        if text != "" {
//            startTypingIndicator()
//        }
        
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        send(text: text, photo: nil, video: nil, audio: nil, location: nil)
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
    
}

