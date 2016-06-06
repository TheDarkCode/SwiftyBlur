//
//  DelayExtensions.swift
//  Ahtau
//
//  Created by Mark Hamilton on 4/11/16.
//  Copyright © 2016 dryverless. All rights reserved.
//

import Foundation

public var GlobalMainQueue: dispatch_queue_t {
    
    return dispatch_get_main_queue()
    
}


public extension NSObject {
    
    /*
     
     example:
     
     object.delay(2) {
     // do after 2 seconds
     }
     
     */
    
    public func delay(delay:Double, closure:(() -> Void)) {
        
        dispatch_after(
            
            dispatch_time(
                
                DISPATCH_TIME_NOW,
                
                Int64(delay * Double(NSEC_PER_SEC))
                
            ), GlobalMainQueue, closure)
        
    }
    
}

/*
 
 example:
 
 delay(2) {
 // do after 2 seconds
 }
 
 */

public func delay(delay:Double, closure:(() -> Void)) {
    
    dispatch_after(
        
        dispatch_time(
            
            DISPATCH_TIME_NOW,
            
            Int64(delay * Double(NSEC_PER_SEC))
            
        ), GlobalMainQueue, closure)
    
}

public func dispatchAfter(delay: Double, closure: (() -> Void)) {
    
    dispatch_after(
        
        dispatch_time(
            
            DISPATCH_TIME_NOW,
            
            Int64(delay * Double(NSEC_PER_SEC))
            
        ), GlobalMainQueue, closure)
    
}