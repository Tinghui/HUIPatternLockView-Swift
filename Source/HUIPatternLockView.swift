//
//  HUIPatternLockView.swift
//  HUIPatternLockView
//
//  Created by ZhangTinghui on 15/10/25.
//  Copyright © 2015年 www.morefun.mobi. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable public class HUIPatternLockView : UIView {
    public static let defaultLineColor = UIColor(red: 248.00/255.00, green: 200.00/255.00, blue: 79.00/255.00, alpha: 1.0)
    public struct Dot: Equatable {
        var tag: Int
        var frame: CGRect
        var center: CGPoint {
            return CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
        }
        var highlighted: Bool
    }
    
    // MARK: Layouts Related Properties
    @IBInspectable public var numberOfRows: Int = 3 {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: true)
        }
    }
    @IBInspectable public var numberOfColumns: Int = 3 {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: true)
        }
    }
    @IBInspectable public var contentInset: UIEdgeInsets = UIEdgeInsetsZero {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: true)
        }
    }
    @IBInspectable public var dotWidth: CGFloat = 60.00 {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: true)
        }
    }
    
    // MARK: Appearance Related Properties
    @IBInspectable public var lineColor: UIColor = HUIPatternLockView.defaultLineColor {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable public var lineWidth: CGFloat = 5.00 {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable public var normalDotImage: UIImage? = nil {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable public var highlightedDotImage: UIImage? = nil {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }

    //MARK: Callback Properties
    public var drawLinePathWithContext: ((path: Array<CGPoint>, context: CGContextRef?) -> Void)? = nil {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    public var drawDotWithContext: ((dot: Dot, context: CGContextRef?) -> Void)? = nil {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    public var didDrawPatternWithPassword: ((lockeView: HUIPatternLockView, dotCounts: Int, password: String?) -> Void)? = nil
    
    //MARK: Private Internal vars
    private var normalDots = Array<Dot>()
    private var highlightedDots = Array<Dot>()
    private var linePath = Array<CGPoint>()
    private var needRecalculateDotsFrame = true
    
    // MARK: init && override
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override public var bounds: CGRect {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: true)
        }
    }
}

// MARK: - Draw Rect
extension HUIPatternLockView {
    private func setLockViewNeedUpdate(needRecalculateDotsFrame needRecalculate: Bool) -> Void {
        if needRecalculate {
            needRecalculateDotsFrame = needRecalculate
        }
        setNeedsDisplay()
    }
    
    public func resetDotsState() -> Void {
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
                let dot = Dot(tag: dotTag++, frame: dotFrame, highlighted: false)
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
            if let drawLineClosure = drawLinePathWithContext {
                CGContextSaveGState(context)
                drawLineClosure(path: linePath, context: context)
                CGContextRestoreGState(context)
            } else {
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
        }
        
        //draw normal dots
        if let drawDotClosure = drawDotWithContext {
            for dot in normalDots {
                CGContextSaveGState(context)
                drawDotClosure(dot: dot, context: context)
                CGContextRestoreGState(context)
            }
        }
        else if let image = normalDotImage {
            for dot in normalDots {
                image.drawInRect(dot.frame)
            }
        }
        
        //draw highlighted dots 
        if let drawDotClosure = drawDotWithContext {
            for dot in highlightedDots {
                CGContextSaveGState(context)
                drawDotClosure(dot: dot, context: context)
                CGContextRestoreGState(context)
            }
        }
        else if let image = highlightedDotImage {
            for dot in highlightedDots {
                image.drawInRect(dot.frame)
            }
        }
    }
}

// MARK: - Record Line Path
extension HUIPatternLockView {
    private func normalDotContainsPoint(point: CGPoint) -> Dot? {
        for dot in normalDots {
            if CGRectContainsPoint(dot.frame, point) {
                return dot
            }
        }
        return nil
    }
    
    private func updateLinePathWithPoint(point: CGPoint) -> Void {
        let linePathPointsCount = linePath.count
        
        if var dot = normalDotContainsPoint(point) {
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
            dot.highlighted = true
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
        if var dot = normalDotContainsPoint(point) {
            dot.highlighted = true
            highlightedDots.append(dot)
            normalDots.removeAtIndex(normalDots.indexOf(dot)!)
        }
        
        linePath = highlightedDots.map({ (dot: Dot) -> CGPoint in
            return dot.center
        })
    }
}

// MARK: - Touches
extension HUIPatternLockView {
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        resetDotsState()
        updateLinePathWithPoint((touches.first?.locationInView(self))!)
        setLockViewNeedUpdate(needRecalculateDotsFrame: false)
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        updateLinePathWithPoint((touches.first?.locationInView(self))!)
        setLockViewNeedUpdate(needRecalculateDotsFrame: false)
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard !highlightedDots.isEmpty else {
            return
        }
        
        endLinePathWithPoint((touches.first?.locationInView(self))!)
        setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        
        //get password and call back
        let dotCounts = highlightedDots.count
        var currentPassword = String()
        for dot in highlightedDots {
            currentPassword.appendContentsOf("[\(dot.tag)]")
        }
        if let callback = didDrawPatternWithPassword {
            callback(lockeView: self, dotCounts: dotCounts, password: currentPassword)
        }
    }
    
    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        resetDotsState()
        setLockViewNeedUpdate(needRecalculateDotsFrame: false)
    }
}

// MARK: - HUIPatternLockView.Dot: Equatable
public func ==(lhs: HUIPatternLockView.Dot, rhs: HUIPatternLockView.Dot) -> Bool {
    return (lhs.tag == rhs.tag && CGRectEqualToRect(lhs.frame, rhs.frame))
}

