//
//  PerformanceUtils.swift
//  Ahtau
//
//  Created by Mark Hamilton on 5/9/16.
//  Copyright © 2016 dryverless. All rights reserved.
//

import Foundation

// Calculate the time it takes to do something.
public func calculateTime(CodeToRun: () -> Void) -> NSTimeInterval {
    
    let start = NSDate()
    
    CodeToRun()
    
    let end = NSDate()
    
    let time = end.timeIntervalSinceDate(start)
    
    return time
    
}