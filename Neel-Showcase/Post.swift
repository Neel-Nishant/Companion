//
//  Post.swift
//  Neel-Showcase
//
//  Created by Neel Nishant on 11/10/16.
//  Copyright © 2016 Neel Nishant. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _postDescription: String!
    private var _imageUrl: String?
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    var postDescription: String {
        return _postDescription
    }
    var imageUrl: String? {
        return _imageUrl
    }
    var likes: Int {
        return _likes
    }
    var username: String {
        return _username
    }
    var postKey: String {
        return _postKey
    }
    
    init(description: String, imageUrl: String?, username: String) {
        self._postDescription = description
        self._imageUrl = imageUrl
        self._username = username
    }
    init(postKey: String, dictionary: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        }
        if let imgUrl = dictionary["imageurl"] as? String {
            self._imageUrl = imgUrl
        }
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc
        }
        self._postRef = DataService.ds.REF_POSTS.child(self._postKey)
    }
    
    func adjustLikes(addlike: Bool) {
        
        if addlike {
            _likes = _likes + 1
        }
        else {
            _likes = _likes - 1
        }
        _postRef.child("likes").setValue(_likes)
    }
}