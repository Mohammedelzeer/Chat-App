//
//  PhotoMessage.swift
//  Chat Clone
//
//  Created by Mohammed on 25/01/2024.
//

import Foundation
import MessageKit
import SwiftUI

class PhotoMessage: NSObject, MediaItem {
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    init (path: String) {
        self.url = URL(fileURLWithPath: path)
        self.placeholderImage = UIImage(named: "placeholder")!
        self.size = CGSize(width: 240, height: 240)
    }
}

