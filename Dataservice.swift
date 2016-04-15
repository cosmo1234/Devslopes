//
//  Dataservice.swift
//  Devslopes
//
//  Created by sagaya Abdulhafeez on 13/04/2016.
//  Copyright © 2016 sagaya Abdulhafeez. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = "https://devlopes.firebaseio.com"

class Dataservice{
    
    static let ds = Dataservice()
    
    private var _REF_BASE = Firebase(url: "\(URL_BASE)")
    
    private var _REF_POST = Firebase(url: "\(URL_BASE)/posts")
    
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/users")
    
    
    var REF_BASE:Firebase{
        return _REF_BASE
    }
    
    var REF_POST:Firebase{
        return _REF_POST
    }
    
    var REF_USERS:Firebase{
        return _REF_USERS
    }
    
    
    func createFirebaseUser(uid:String,user:Dictionary<String,String>){
        
        //it wil append path like https://devlopes.firebaseio.com/users/sajhuidsj

        REF_USERS.childByAppendingPath(uid).setValue(user)
        
    }
    
}