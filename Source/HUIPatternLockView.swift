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
    private enum State {
        case Normal
        case Succeeded
        case Failed
    }
    
    public static let defaultColor = UIColor(red: 248.00/255.00, green: 200.00/255.00, blue: 79.00/255.00, alpha: 1.0)
    public static let defaultSucceededColor = UIColor.greenColor()
    public static let defaultFailedColor = UIColor.redColor()
    
    //MARK: Layouts Related Properties
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
    
    //MARK: Appearance Related Properties
    @IBInspectable public var lineColor: UIColor = HUIPatternLockView.defaultColor {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable public var succeededLineColor: UIColor = HUIPatternLockView.defaultSucceededColor {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable public var failedLineColor: UIColor = HUIPatternLockView.defaultFailedColor {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable public var lineWidth: CGFloat = 5.00 {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable public var normalOuterCircleColor: UIColor = UIColor.blackColor() {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable public var highlightedOuterCircleColor: UIColor = HUIPatternLockView.defaultColor {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable public var succeededOuterCircleColor: UIColor = HUIPatternLockView.defaultSucceededColor {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable public var failedOuterCircleColor: UIColor = HUIPatternLockView.defaultFailedColor {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable public var normalInnerDotColor: UIColor = UIColor.blackColor() {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable public var highlightedInnerDotColor: UIColor = HUIPatternLockView.defaultColor {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable public var succeededInnerDotColor: UIColor = HUIPatternLockView.defaultSucceededColor {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable public var failedInnerDotColor: UIColor = HUIPatternLockView.defaultFailedColor {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable public var innerDotRadius: CGFloat = 15.0 {
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
    @IBInspectable public var succeededDotImage: UIImage? = nil {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    @IBInspectable public var failedDotImage: UIImage? = nil {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    
    public var password: String?
    public var resetDelay: NSTimeInterval = 1
    
    
    //MARK: Callback
    public var didDrawPatternWithPassword: ((lockeView: HUIPatternLockView, dotCounts: Int, password: String?) -> Void)? = nil
    public var willResetPatternWithPassword: ((lockeView: HUIPatternLockView, dotCounts: Int, password: String?) -> Void)? = nil
    
    //MARK: Private Internal vars
    private var normalDots = Array<HUIPatternLockViewDot>()
    private var highlightedDots = Array<HUIPatternLockViewDot>()
    private var succeededDots = Array<HUIPatternLockViewDot>()
    private var failedDots = Array<HUIPatternLockViewDot>()
    private var linePath = Array<CGPoint>()
    private var needRecalculateDotsFrame = true
    private var state: State = .Normal
    private var resetTimer: NSTimer?

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
        succeededDots.removeAll()
        failedDots.removeAll()
        linePath.removeAll()
        state = .Normal
        resetTimer?.invalidate()
        
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
            var color = lineColor
            switch state {
            case .Succeeded:
                color = succeededLineColor
            case .Failed:
                color = failedLineColor
            default:
                color = lineColor
            }
            CGContextSetStrokeColorWithColor(context, color.CGColor)
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
        
        if let image = succeededDotImage {
            for dot in succeededDots {
                image.drawInRect(dot.frame)
            }
        } else {
            CGContextSetFillColorWithColor(context, succeededInnerDotColor.CGColor)
            CGContextSetStrokeColorWithColor(context, succeededOuterCircleColor.CGColor)
            for dot in succeededDots {
                drawDot(dot)
            }
        }
        
        if let image = failedDotImage {
            for dot in failedDots {
                image.drawInRect(dot.frame)
            }
        } else {
            CGContextSetFillColorWithColor(context, failedInnerDotColor.CGColor)
            CGContextSetStrokeColorWithColor(context, failedOuterCircleColor.CGColor)
            for dot in failedDots {
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
        guard !highlightedDots.isEmpty else {
            resetDotsState()
            return
        }
        
        endLinePathWithPoint((touches.first?.locationInView(self))!)
        
        let dotCounts = highlightedDots.count
        var currentPassword = String()
        for dot in highlightedDots {
            currentPassword.appendContentsOf("[\(dot.tag)]")
        }
        
        //if the correct password is set, redraw the dots and line in a success/failed state
        if let pwd = password {
            let succeeded = pwd == currentPassword
            
            if (succeeded) {
                state = .Succeeded
                succeededDots.appendContentsOf(normalDots)
                succeededDots.appendContentsOf(highlightedDots)
            } else {
                state = .Failed
                failedDots.appendContentsOf(normalDots)
                failedDots.appendContentsOf(highlightedDots)
            }
            
            
            normalDots.removeAll()
            highlightedDots.removeAll()
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
        
        if let callback = didDrawPatternWithPassword {
            callback(lockeView: self, dotCounts: dotCounts, password: currentPassword)
        }
        
        //reset dots state after resetDelay seconds. Make the line display resetDelay seconds
        resetTimer?.invalidate()
        resetTimer = NSTimer.scheduledTimerWithTimeInterval(resetDelay, target: self, selector: "timerFired:", userInfo: ["dotCounts": dotCounts, "password": currentPassword], repeats: false)
    }
    
    func timerFired(timer: NSTimer) {
        let dotCounts = timer.userInfo!["dotCounts"] as! Int
        let currentPassword = timer.userInfo!["password"] as! String
        if let callback = self.willResetPatternWithPassword {
            callback(lockeView: self, dotCounts: dotCounts, password: currentPassword)
        }
        self.resetDotsState()
        self.setNeedsDisplay()
    }
    
    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        resetDotsState()
        setNeedsDisplay()
    }
}




