//
//  VideoMessage.swift
//  Chat Clone
//
//  Created by Mohammed on 26/01/2024.
//

import Foundation
import MessageKit
import SwiftUI

class VideoMessage: NSObject, MediaItem {
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    init (url: URL?) {
        self.url = url
        self.placeholderImage = UIImage(named: "placeholder")!
        self.size = CGSize(width: 240, height: 240)
    }
}
