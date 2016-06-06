//
//  SwiftyBlurFilter.swift
//  SwiftyBlur
//
//  Updates by Mark Hamilton on 6/5/16.
//  Copyright © 2016 dryverless. All rights reserved.
//
//  Based on MotionBlur by Guanshan Liu on 18/10/2014.
//  Copyright (c) 2014 guanshanliu. All rights reserved.
//

import UIKit
import CoreImage

let kernelSource =  "kernel vec4 motionBlur(sampler image, vec2 velocity, float numSamplesInput) { "    +
    "int numSamples = int(floor(numSamplesInput)); "                                +
    "vec4 sum = vec4(0.0), avg = vec4(0.0); "                                       +
    "vec2 dc = destCoord(), offset = -velocity; "                                   +
    "for (int i=0; i < (numSamples * 2 + 1); i++) { "                               +
    "sum += sample (image, samplerTransform (image, dc + offset)); "            +
    "offset += velocity / float(numSamples); "                                  +
    "} "                                                                            +
    "avg = sum / float((numSamples * 2 + 1)); "                                     +
    "return avg; "                                                                  +
"}"

public class SwiftyBlurFilter: CIFilter {
    
    let kernel = CIKernel(string: kernelSource)
    
    let kMotionBlurSampleCountKey = "kMotionBlurSampleCountKey"
    var numberOfSample: Int = 5
    
    var radius: Float = 40
    var angle: Float = Float(M_PI_2)
    var inputImage: CIImage?
    
    override public func setValue(value: AnyObject?, forKey key: String) {
        
        switch key {
            
        case let k where k == kMotionBlurSampleCountKey:
            if let number = value as? NSNumber {
                numberOfSample = number.integerValue
            }
            
        case let k where k == kCIInputRadiusKey:
            if let number = value as? NSNumber {
                radius = number.floatValue
            }
            
        case let k where k == kCIInputAngleKey:
            if let number = value as? NSNumber {
                angle = number.floatValue
            }
            
        case let k where k == kCIInputImageKey:
            if let image = value as? CIImage {
                inputImage = image
            }
            
        default:
            super.setValue(value, forKey: key)
            
        }
        
    }
    
    override public func valueForKey(key: String) -> AnyObject? {
        
        switch key {
            
        case let k where k == kMotionBlurSampleCountKey:
            return NSNumber(integer: numberOfSample)
            
        case let k where k == kCIInputRadiusKey:
            return NSNumber(float: radius)
            
        case let k where k == kCIInputAngleKey:
            return NSNumber(float: angle)
            
        case let k where k == kCIInputImageKey:
            return inputImage
            
        default:
            return super.valueForKey(key)
            
        }
        
    }
    
    override public var outputImage: CIImage {
        let x = CGFloat(radius * cosf(angle))
        let y = CGFloat(radius * sin(angle))
        let dod = CGRectInset(inputImage!.extent, -abs(x), -abs(y))
        
        return kernel!.applyWithExtent(dod, roiCallback: { (index, rect) -> CGRect in
            CGRectInset(rect, -abs(x), -abs(y))
            }, arguments: [inputImage!, CIVector(x: x, y: y), numberOfSample])!
    }
    
}

internal func motionBlur(angle: Float) -> Filter {
    return { image in
        let parameters: Parameters = [
            kCIInputAngleKey: angle,
            kCIInputImageKey: image
        ]
        let filter = SwiftyBlurFilter()
        for (key, value) in parameters {
            filter.setValue(value, forKey: key)
        }
        return filter.outputImage
    }
}
