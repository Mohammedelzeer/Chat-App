//
//  FCollectionRefrance.swift
//  Chat Clone
//
//  Created by Mohammed on 07/01/2024.
//

import Foundation
import Firebase

enum FCollectionRefrance: String {
    case User
    case Chat
    case Message
    case Typing
    case Channel
}

func firestoreRefrance (_ collectionRefrance: FCollectionRefrance) ->
    CollectionReference {
    
    return Firestore.firestore().collection(collectionRefrance.rawValue)
}
