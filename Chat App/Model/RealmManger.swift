//
//  RealmManger.swift
//  Chat Clone
//
//  Created by Mohammed on 18/01/2024.
//

import Foundation
import RealmSwift

class RealmManger {
    
    static let shared = RealmManger()
    
    let realm = try! Realm()
    
    private init () {}
    
    func save<T: Object> (_ object: T) {
        
        do {
            try realm.write {
                realm.add(object, update: .all)
            }
        } catch {
            print("error saving date ", error.localizedDescription)
        }
    }
}
