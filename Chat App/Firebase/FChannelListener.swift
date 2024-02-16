//
//  FChannelListener.swift
//  Chat Clone
//
//  Created by Mohammed on 03/02/2024.
//

import Foundation
import Firebase

class FChannelListener {
    
    static let shared = FChannelListener()
    var userChannelsListener: ListenerRegistration!
    var SubscribedChannelsListener: ListenerRegistration!
    
    private init() {}
    
    
    //MARK:- add channels
    
    func saveChannel(_ channel: Channel) {
        
        do {
            try firestoreRefrance(.Channel).document(channel.id).setData(from: channel)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //MARK:- Download channels
    
    func downloadUserChannels(completion: @escaping (_ userChannels: [Channel])->Void) {
        
        userChannelsListener = firestoreRefrance(.Channel).whereField(kADMINID, isEqualTo: User.currentId).addSnapshotListener({ (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {return}
            var userChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            userChannels.sort(by: {$0.memberIds.count > $1.memberIds.count})
            completion(userChannels)
        })
    }
    
    func downloadSubscribedChannels(completion: @escaping (_ userChannels: [Channel])->Void) {
        
        SubscribedChannelsListener = firestoreRefrance(.Channel).whereField(kMEMBERIDS, arrayContains: User.currentId).addSnapshotListener({ (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {return}
            var subscribedChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            subscribedChannels.sort(by: {$0.memberIds.count > $1.memberIds.count})
            completion(subscribedChannels)
        })
    }

    func downloadAllChannels (completion: @escaping(_ allChannels: [Channel])->Void) {
        firestoreRefrance(.Channel).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {return}
            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            allChannels = self.removeUserChannels(allChannels)
            allChannels.sort(by: {$0.memberIds.count > $1.memberIds.count})
            completion(allChannels)
        }
    }
    
    //MARK:- helper function
    
    func removeUserChannels(_ allChannels: [Channel]) -> [Channel] {
        
        var newChannels : [Channel] = []
        
        for channel in allChannels {
            if !channel.memberIds.contains(User.currentId) {
                newChannels.append(channel)
            }
        }
        return newChannels
    }
    
    
}

