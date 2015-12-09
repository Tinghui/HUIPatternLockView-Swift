//
//  HUIPatternLockView.swift
//  HUIPatternLockView
//
//  Created by ZhangTinghui on 15/10/25.
//  Copyright © 2015年 www.morefun.mobi. All rights reserved.
//

import UIKit
import Foundation

private struct HUIPatternLockViewDot: Equatable {
    var tag: Int
    var frame: CGRect
    var center: CGPoint {
        return CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
    }
}

private func ==(lhs: HUIPatternLockViewDot, rhs: HUIPatternLockViewDot) -> Bool {
    return (lhs.tag == rhs.tag && CGRectEqualToRect(lhs.frame, rhs.frame))
}

@IBDesignable public class HUIPatternLockView : UIView {
    static let defaultColor = UIColor(red: 248.00/255.00, green: 200.00/255.00, blue: 79.00/255.00, alpha: 1.0)
    
    //MARK: Layouts Related Properties
    @IBInspectable var numberOfRows: Int = 3 {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: true)
        }
    }
    @IBInspectable var numberOfColumns: Int = 3 {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: true)
        }
    }
    @IBInspectable var contentInset: UIEdgeInsets = UIEdgeInsetsZero {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: true)
        }
    }
    @IBInspectable var dotWidth: CGFloat = 60.00 {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: true)
        }
    }
    
    //MARK: Appearance Related Properties
    @IBInspectable var lineColor: UIColor = HUIPatternLockView.defaultColor {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable var lineWidth: CGFloat = 5.00 {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable var normalOuterCircleColor: UIColor = UIColor.blackColor() {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable var highlightedOuterCircleColor: UIColor = HUIPatternLockView.defaultColor {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable var normalInnerDotColor: UIColor = UIColor.blackColor() {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable var highlightedInnerDotColor: UIColor = HUIPatternLockView.defaultColor {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable var innerDotRadius: CGFloat = 15.0 {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable var normalDotImage: UIImage? = nil {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable var highlightedDotImage: UIImage? = nil {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    
    
    //MARK: Callback
    var didDrawPatternWithPassword: ((lockeView: HUIPatternLockView, dotCounts: Int, password: String?) -> Void)? = nil
    
    //MARK: Private Internal vars
    private var normalDots = Array<HUIPatternLockViewDot>()
    private var highlightedDots = Array<HUIPatternLockViewDot>()
    private var linePath = Array<CGPoint>()
    private var needRecalculateDotsFrame = true
    
    override public var bounds: CGRect {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: true)
        }
    }
    
    //MARK: Deinit/Init
    deinit {
        //TODO: need deinit?
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
}

extension HUIPatternLockView {
    //MARK: Draw Rect
    private func setLockViewNeedUpdate(needRecalculateDotsFrame needRecalculate: Bool) -> Void {
        if needRecalculate {
            needRecalculateDotsFrame = needRecalculate
        }
        setNeedsDisplay()
    }
    
    private func resetDotsState() -> Void {
        //reset dots arrays
        normalDots.removeAll()
        highlightedDots.removeAll()
        linePath.removeAll()
        
        //calculate dot width with bounds
        let dotsAreaWidth = CGRectGetWidth(bounds) - contentInset.left - contentInset.right
        let dotsAreaHeight = CGRectGetHeight(bounds) - contentInset.top - contentInset.bottom
        
        //throw exception if dots is too big
        if (dotWidth * CGFloat(numberOfColumns) > CGFloat(dotsAreaWidth) || dotWidth * CGFloat(numberOfRows) > CGFloat(dotsAreaHeight)) {
            print("HUIPatternLockView resetDotsState() -> Error: The dot is too big to be layout in content area")
        }
        
        let widthPerDots = dotsAreaWidth / CGFloat(numberOfColumns)
        let heightPerDots = dotsAreaHeight / CGFloat(numberOfRows)
        
        var dotTag = 0
        for (var row = 0; row < numberOfRows; row++) {
            for (var column = 0; column < numberOfColumns; column++) {
                let dotCenter = CGPointMake(contentInset.left + (CGFloat(column) + 0.5) * widthPerDots ,
                    contentInset.top + (CGFloat(row) + 0.5) * heightPerDots)
                let dotFrame = CGRect(x: dotCenter.x - dotWidth * 0.5, y: dotCenter.y - dotWidth * 0.5,
                    width: dotWidth, height: dotWidth)
                let dot = HUIPatternLockViewDot(tag: dotTag++, frame: dotFrame)
                normalDots.append(dot)
            }
        }
    }
    
    public override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        //recalculate dots' frame if needed
        if (needRecalculateDotsFrame) {
            resetDotsState()
            needRecalculateDotsFrame = false
        }
        
        //draw line
        if !linePath.isEmpty {
            CGContextSetStrokeColorWithColor(context, lineColor.CGColor)
            CGContextSetLineWidth(context, lineWidth)
            CGContextSetLineJoin(context, .Round)
            
            let firstPoint = linePath.first
            for point in linePath {
                if point == firstPoint {
                    CGContextMoveToPoint(context, point.x, point.y)
                }
                else {
                    CGContextAddLineToPoint(context, point.x, point.y)
                }
            }
            
            CGContextDrawPath(context, .Stroke)
        }
        

        //draw normal dot images
        CGContextSetLineWidth(context, 1)

        if let image = normalDotImage {
            for dot in normalDots {
                image.drawInRect(dot.frame)
            }
        } else {
            CGContextSetFillColorWithColor(context, normalInnerDotColor.CGColor)
            CGContextSetStrokeColorWithColor(context, normalOuterCircleColor.CGColor)
            for dot in normalDots {
                drawDot(dot)
            }
        }
        
        //draw highlighted dot images 
        if let image = highlightedDotImage {
            for dot in highlightedDots {
                image.drawInRect(dot.frame)
            }
        } else {
            CGContextSetFillColorWithColor(context, highlightedInnerDotColor.CGColor)
            CGContextSetStrokeColorWithColor(context, highlightedOuterCircleColor.CGColor)
            for dot in highlightedDots {
                drawDot(dot)
            }
        }
    }

    private func drawDot(dot: HUIPatternLockViewDot) {
        let context = UIGraphicsGetCurrentContext()
        let x = CGRectGetMidX(dot.frame)
        let y = CGRectGetMidY(dot.frame)
        CGContextMoveToPoint(context, x, y)
        CGContextAddArc(context, x, y, innerDotRadius, 0, CGFloat(2*M_PI), 1)
        CGContextFillPath(context)
        CGContextStrokeEllipseInRect(context, dot.frame)
    }
}


extension HUIPatternLockView {
    //MARK: Record Line Path
    private func normalDotContainsPoint(point: CGPoint) -> HUIPatternLockViewDot? {
        for dot in normalDots {
            if CGRectContainsPoint(dot.frame, point) {
                return dot
            }
        }
        return nil
    }
    
    private func updateLinePathWithPoint(point: CGPoint) -> Void {
        let linePathPointsCount = linePath.count
        
        if let dot = normalDotContainsPoint(point) {
            if (linePathPointsCount <= 0) {
                //if no any points in linePath. use this dot's center to be the linePath start and end point
                linePath.append(dot.center)
                linePath.append(dot.center)
            }
            else {
                //else insert a new point into the path
                linePath.insert(dot.center, atIndex: linePathPointsCount-1)
            }
            
            //mark this dot as highlighted
            highlightedDots.append(dot);
            normalDots.removeAtIndex(normalDots.indexOf(dot)!)
        }
        else {
            
            if (linePathPointsCount == 0) {
                //linePath must start with a dot's center
                return
            }
            else if (linePathPointsCount == 1) {
                //if linePath has a start point, this point is treat as end point
                linePath.append(point)
            }
            else {
                //if line path has at least two points. always use this point to update the end point
                linePath[linePathPointsCount-1] = point
            }
        }
    }
    
    private func endLinePathWithPoint(point: CGPoint) -> Void {
        if let dot = normalDotContainsPoint(point) {
            highlightedDots.append(dot)
            normalDots.removeAtIndex(normalDots.indexOf(dot)!)
        }
        
        linePath = highlightedDots.map({ (dot: HUIPatternLockViewDot) -> CGPoint in
            return dot.center
        })
    }
}

extension HUIPatternLockView {
    //MARK: Touches
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        resetDotsState()
        updateLinePathWithPoint((touches.first?.locationInView(self))!)
        setNeedsDisplay()
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        updateLinePathWithPoint((touches.first?.locationInView(self))!)
        setNeedsDisplay()
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        endLinePathWithPoint((touches.first?.locationInView(self))!)
        
        let dotCounts = highlightedDots.count
        var password = String()
        for dot in highlightedDots {
            password.appendContentsOf("[\(dot.tag)]")
        }
        
        //reset dots state after 0.5. Make the line display 0.5 seconds
        let delayInSeconds = 0.5;
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.resetDotsState()
            self.setNeedsDisplay()
        }
        
        //notify the delegate
        if (dotCounts <= 0) {
            return;
        }
        
        if let callback = didDrawPatternWithPassword {
            callback(lockeView: self, dotCounts: dotCounts, password: password)
        }
    }
    
    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        resetDotsState()
        setNeedsDisplay()
    }
}




