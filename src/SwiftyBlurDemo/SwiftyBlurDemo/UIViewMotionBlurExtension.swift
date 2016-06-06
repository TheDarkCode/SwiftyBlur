//
//  UIViewMotionBlurExtension.swift
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

private var kUIViewBlurLayer: UInt8 = 0
private var kUIViewDisplayLink: UInt8 = 0
private var kUIViewLastPosition: UInt8 = 0

func CGImageCreateByApplyingMotionBlur(snapshot: UIImage, angle: Float) -> CGImageRef {
    let context = CIContext(options: [ kCIContextPriorityRequestLow: NSNumber(bool: true) ])
    let inputImage = CIImage(CGImage: snapshot.CGImage!)
    let outputImage = motionBlur(angle)(inputImage)
    let blurredImageRef = context.createCGImage(outputImage, fromRect: outputImage.extent)
    return blurredImageRef
}

extension UIView {
    
    // MARK: Properties
    var blurLayer: CALayer? {
        get {
            return objc_getAssociatedObject(self, &kUIViewBlurLayer) as? CALayer
        }
        set {
            objc_setAssociatedObject(self, &kUIViewBlurLayer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var displayLink: CADisplayLink? {
        get {
            return objc_getAssociatedObject(self, &kUIViewDisplayLink) as? CADisplayLink
        }
        set {
            objc_setAssociatedObject(self, &kUIViewDisplayLink, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    var lastPosition: NSValue? {
        get {
            return objc_getAssociatedObject(self, &kUIViewLastPosition) as? NSValue
        }
        set {
            objc_setAssociatedObject(self, &kUIViewLastPosition, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: Public methods
    func enableMotionBlur(angle: Float, completion: (Void -> Void)?) {
        // snapshot has to be performed on the main thread
        // TODO: WHY??
        let snapshot = self.layerSnapshot()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let blurredImageRef: CGImageRef = CGImageCreateByApplyingMotionBlur(snapshot, angle: angle)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.disableMotionBlur()
                
                let blurLayer = CALayer()
                blurLayer.contents = blurredImageRef
                blurLayer.opacity = 0
                
                let scale = UIScreen.mainScreen().scale
                let difference = CGSize(width: CGFloat(CGImageGetWidth(blurredImageRef)) / scale - CGRectGetWidth(self.frame), height: CGFloat(CGImageGetHeight(blurredImageRef)) / scale - CGRectGetHeight(self.frame))
                blurLayer.frame = CGRectInset(self.bounds, -difference.width / 2, -difference.height / 2)
                
                blurLayer.actions = [ "opacity": NSNull() ]
                self.layer.addSublayer(blurLayer)
                self.blurLayer = blurLayer
                
                let displayLink = CADisplayLink(target: self, selector: #selector(UIView.tick(_:)))
                displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
                self.displayLink = displayLink
                
                if let complete = completion {
                    complete()
                }
            })
        }
    }
    
    func disableMotionBlur() {
        displayLink?.invalidate()
        blurLayer?.removeFromSuperlayer()
    }
    
    // MARK: Internal methods
    func layerSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextFillRect(context, bounds)
        
        // good explanation of differences between drawViewHierarchyInRect:afterScreenUpdates: and renderInContext: https://github.com/radi/LiveFrost/issues/10#issuecomment-28959525
        layer.renderInContext(context!)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshot
    }
    
    func tick(displayLink: CADisplayLink) {
        let realPosition = self.layer.presentationLayer()!.position
        
        if let lastPostionValue = lastPosition {
            // TODO: there's an assumption that the animation has constant FPS. The following code should also use a timestamp of the previous frame.
            
            let lastPositionPoint = lastPostionValue.CGPointValue()
            let dx = Float(abs(realPosition.x - lastPositionPoint.x))
            let dy = Float(abs(realPosition.y - lastPositionPoint.y))
            let delta = sqrtf(powf(dx, 2) + powf(dy, 2))
            
            // A rough approximation of a good looking blur. The larger the speed, the larger opacity of the blur layer.
            let unboundedOpacity = log2f(delta) / 5
            let opacity = fmaxf(fminf(unboundedOpacity, 1), 0)
            blurLayer?.opacity = opacity
        }
        
        lastPosition = NSValue(CGPoint: realPosition)
    }
    
}