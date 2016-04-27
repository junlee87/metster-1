//
//  Users.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/31/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import Foundation

class Users: NSObject {
    
    var name : AnyObject?
    var email : AnyObject?
    var profpic : AnyObject?
    var fbid : AnyObject?
    var lat : AnyObject?
    var long : AnyObject?
    var food_pref : AnyObject?
    var movie_pref : AnyObject?
    var what : AnyObject?
    
    var eventName : AnyObject?
    var query : AnyObject?
    var event_id : AnyObject?
    var event_date : AnyObject?
    var event_time : AnyObject?
    var event_notes : AnyObject?
    var invited_members : AnyObject?
    var event_members : AnyObject?
    
    var place_info : AnyObject?
    var place_id : AnyObject?
    var place_name : AnyObject?
    
    var places : NSMutableArray?
    var place_ids : NSMutableArray?
    var host_email : AnyObject?
    
    var user_friends: NSArray?
    var hosted : NSArray?
    var joined : NSArray?
    var pending : NSArray?
    var gender : AnyObject?
    
    var event_dic =  [String: AnyObject?]()
    
    class func sharedInstance() -> Users {
        struct Singleton {
            static var sharedInstance = Users()
        }
        return Singleton.sharedInstance
    }
}


