//
//  Post.swift
//  Devslopes
//
//  Created by sagaya Abdulhafeez on 14/04/2016.
//  Copyright © 2016 sagaya Abdulhafeez. All rights reserved.
//

import Foundation

class Post{
    
    private var _postDescription:String!
    private var _imageurl:String?
    private var _likes:Int!
    private var _userName:String!
    private var _postKey:String!
    
    var postDescription:String!{
        return _postDescription
    }
    var imageUrl:String?{
        return _imageurl
    }
    
    var likes:Int{
        return _likes
    }
    var userName:String{
        return _userName
    }

    init(description:String,imageUrl:String?, userName:String!){
        self._postDescription = description
        self._imageurl = imageUrl
        self._userName = userName
        
    }
    
    
    init(postKey:String,dictionary:Dictionary<String,AnyObject>){
        self._postKey = postKey
        if let likes = dictionary["totalLikes"] as? Int{
            self._likes = likes
        }
        
        if let imageUrl = dictionary["image_url"] as? String {
            self._imageurl = imageUrl
        }
        
        if let desc = dictionary["description"] as? String{
            self._postDescription = desc
        }
        
    }
    
    
    
}