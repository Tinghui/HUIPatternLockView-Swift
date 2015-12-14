//
//  ViewController.swift
//  HUIPatternLockViewDemo
//
//  Created by ZhangTinghui on 15/10/25.
//  Copyright © 2015年 www.morefun.mobi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var lockView: HUIPatternLockView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configuareLockViewWithImages()
        
        /* un-comment this line to use custom drawing api */
//        configuareLockViewWithCustomDrawingCodes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Custom LockView with images
extension ViewController {
    private func configuareLockViewWithImages() {
        let defaultLineColor = HUIPatternLockView.defaultLineColor
        let correctLineColor = UIColor.greenColor()
        let wrongLineColor = UIColor.redColor()
        
        let normalImage = UIImage(named: "dot_normal")
        let highlightedImage = UIImage(named: "dot_highlighted")
        let correctImage = highlightedImage?.tintImage(correctLineColor)
        let wrongImage = highlightedImage?.tintImage(wrongLineColor)
        
        
        lockView.didDrawPatternWithPassword = { (lockView: HUIPatternLockView, count: Int, password: String?) -> Void in
            guard count > 0 else {
                return
            }
            
            let unlockPassword = "[0][3][6][7][8]"
            
            self.label.text = "Got Password: " + password!
            if password == unlockPassword {
                lockView.lineColor = correctLineColor
                lockView.normalDotImage = correctImage
                lockView.highlightedDotImage = correctImage
            }
            else {
                lockView.lineColor = wrongLineColor
                lockView.normalDotImage = wrongImage
                lockView.highlightedDotImage = wrongImage
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                lockView.resetDotsState()
                lockView.lineColor = defaultLineColor
                lockView.normalDotImage = normalImage
                lockView.highlightedDotImage = highlightedImage
            }
        }
    }
}

// MARK: - Custom LockView Drawing
extension ViewController {
    private enum LockViewPasswordState: Int {
        case Normal
        case Correct
        case Wrong
    }
    
    private func configuareLockViewWithCustomDrawingCodes() {
        lockView.drawLinePathWithContext = { [unowned self] (path, context) -> Void in
            self.drawLockViewLinePath(path, context: context)
        }
        
        lockView.drawDotWithContext = { [unowned self] (dot, context) -> Void in
            self.drawLockViewDot(dot, context: context)
        }
        
        lockView.didDrawPatternWithPassword = { [unowned self] (lockView, count, password) -> Void in
            self.handleLockViewDidDrawPassword(lockView, count: count, password: password)
        }
    }
    
    private func colorForLockViewState(state: LockViewPasswordState, useHighlightedColor: Bool) -> UIColor {
        switch state {
        case .Correct:
            return UIColor.greenColor()
        case .Wrong:
            return UIColor.redColor()
        default:
            if useHighlightedColor {
                return HUIPatternLockView.defaultLineColor
            }
            else {
                return UIColor.blackColor()
            }
        }
    }
    
    private func resetLockView(lockView: HUIPatternLockView) {
        lockView.resetDotsState()
        lockView.drawLinePathWithContext = { [unowned self] (path, context) -> Void in
            self.drawLockViewLinePath(path, context: context)
        }
        lockView.drawDotWithContext = { [unowned self] (dot, context) -> Void in
            self.drawLockViewDot(dot, context: context)
        }
        lockView.userInteractionEnabled = true
    }
    
    private func handleLockViewDidDrawPassword(lockView: HUIPatternLockView, count: Int, password: String?) {
        guard count > 0 else {
            resetLockView(lockView)
            return
        }
        
        let unlockPassword = "[0][3][6][7][8]"
        var state = LockViewPasswordState.Wrong
        if password == unlockPassword {
            state = .Correct
        }
        
        self.label.text = "Got Password: " + password!
        lockView.userInteractionEnabled = false
        lockView.drawLinePathWithContext = { [unowned self] (path, context) -> Void in
            self.drawLockViewLinePath(path, context: context, state: state)
        }
        lockView.drawDotWithContext = { [unowned self] (dot, context) -> Void in
            self.drawLockViewDot(dot, context: context, state: state)
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.resetLockView(lockView)
        }
    }
    
    private func drawLockViewLinePath(path: Array<CGPoint>, context: CGContextRef?, state: LockViewPasswordState = .Normal) {
        if path.isEmpty {
            return
        }
        
        let color = colorForLockViewState(state, useHighlightedColor: true)
        let dashLengths: [CGFloat] = [5.0, 10.0, 5.0]
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextSetLineWidth(context, 3)
        CGContextSetLineCap(context, .Round)
        CGContextSetLineJoin(context, .Round)
        CGContextSetLineDash(context, 0, dashLengths, 3)
        
        let fistPoint = path.first
        for point in path {
            if point == fistPoint {
                CGContextMoveToPoint(context, point.x, point.y)
            }
            else {
                CGContextAddLineToPoint(context, point.x, point.y)
            }
        }
        
        CGContextDrawPath(context, .Stroke)
    }
    
    private func drawLockViewDot(dot: HUIPatternLockView.Dot, context: CGContextRef?, state: LockViewPasswordState = .Normal) {
        let dotCenter = dot.center
        let innerDotRadius: CGFloat = 15.0
        let color = colorForLockViewState(state, useHighlightedColor: dot.highlighted)
        
        CGContextSetLineWidth(context, 1)
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        
        CGContextMoveToPoint(context, dotCenter.x, dotCenter.y)
        CGContextBeginPath(context)
        CGContextAddArc(context, dotCenter.x, dotCenter.y, innerDotRadius, 0, CGFloat(2*M_PI), 1)
        CGContextClosePath(context)
        CGContextFillPath(context)
        CGContextStrokeEllipseInRect(context, dot.frame)
    }
}

extension UIImage {
    public func tintImage(tintColor: UIColor) -> UIImage {
        return tintImage(tintColor, blendMode: .DestinationIn)
    }
    
    public func gradientTintImage(tintColor: UIColor) -> UIImage {
        return tintImage(tintColor, blendMode: .Overlay)
    }
    
    public func tintImage(tintColor: UIColor, blendMode: CGBlendMode) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let bounds = CGRect(origin: CGPointZero, size: size)
        tintColor.setFill()
        UIRectFill(bounds)
        
        drawInRect(bounds, blendMode: blendMode, alpha: 1.0)
        
        //draw again to save alpha channel
        if blendMode != .DestinationIn {
            drawInRect(bounds, blendMode: .DestinationIn, alpha: 1.0)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

