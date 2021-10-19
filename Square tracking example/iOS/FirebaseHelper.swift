//
//  FirebaseHelper.swift
//  artoolkitX Square Tracking Example
//
//  Created by user on 18.10.21.
//  Copyright © 2021 artoolkit.org. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage


enum FirebaseStrings {
    static let postDirectory = "posts"
}

enum FirebaseHelper {
    
    private static let databaseReference = Database.database().reference()
    private static let storageReference = Storage.storage().reference()
    static let postsReference = databaseReference.child(FirebaseStrings.postDirectory)
    
}
