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
        public var tag: Int
        public var frame: CGRect
        public var center: CGPoint {
            return CGPoint(x: frame.midX, y: frame.midY)
        }
        public var highlighted: Bool
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
    @IBInspectable public var contentInset: UIEdgeInsets = UIEdgeInsets.zero {
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
    public var drawLinePathWithContext: ((_ path: Array<CGPoint>, _ context: CGContext?) -> Void)? = nil {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    public var drawDotWithContext: ((_ dot: Dot, _ context: CGContext?) -> Void)? = nil {
        didSet {
            setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        }
    }
    public var didDrawPatternWithPassword: ((_ lockeView: HUIPatternLockView, _ dotCounts: Int, _ password: String?) -> Void)? = nil
    
    //MARK: Private Internal vars
    internal var normalDots = Array<Dot>()
    internal var highlightedDots = Array<Dot>()
    internal var linePath = Array<CGPoint>()
    internal var needRecalculateDotsFrame = true
    
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
    internal func setLockViewNeedUpdate(needRecalculateDotsFrame needRecalculate: Bool) -> Void {
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
        let dotsAreaWidth = bounds.width - contentInset.left - contentInset.right
        let dotsAreaHeight = bounds.height - contentInset.top - contentInset.bottom
        
        //throw exception if dots is too big
        if (dotWidth * CGFloat(numberOfColumns) > CGFloat(dotsAreaWidth) || dotWidth * CGFloat(numberOfRows) > CGFloat(dotsAreaHeight)) {
            print("HUIPatternLockView resetDotsState() -> Error: The dot is too big to be layout in content area")
        }
        
        let widthPerDots = dotsAreaWidth / CGFloat(numberOfColumns)
        let heightPerDots = dotsAreaHeight / CGFloat(numberOfRows)
        
        var dotTag = 0
        for row in 0 ..< numberOfRows{
            for column in 0 ..< numberOfColumns {
                let dotCenter = CGPoint(x: contentInset.left + (CGFloat(column) + 0.5) * widthPerDots
                    , y: contentInset.top + (CGFloat(row) + 0.5) * heightPerDots)
                let dotFrame = CGRect(x: dotCenter.x - dotWidth * 0.5, y: dotCenter.y - dotWidth * 0.5,
                                      width: dotWidth, height: dotWidth)
                let dot = Dot(tag: dotTag, frame: dotFrame, highlighted: false)
                dotTag += 1
                normalDots.append(dot)
            }
        }
    }
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        //recalculate dots' frame if needed
        if (needRecalculateDotsFrame) {
            resetDotsState()
            needRecalculateDotsFrame = false
        }
        
        //draw line
        if !linePath.isEmpty {
            if let drawLineClosure = drawLinePathWithContext {
                context.saveGState()
                drawLineClosure(linePath, context)
                context.restoreGState()
            }
            else {
                context.setStrokeColor(lineColor.cgColor)
                context.setLineWidth(lineWidth)
                context.setLineJoin(.round)
                
                let firstPoint = linePath.first
                for point in linePath {
                    if point == firstPoint {
                        context.move(to: point)
                    }
                    else {
                        context.addLine(to: point)
                    }
                }
                
                context.drawPath(using: .stroke)
            }
        }
        
        //draw normal dots
        if let drawDotClosure = drawDotWithContext {
            for dot in normalDots {
                context.saveGState()
                drawDotClosure(dot, context)
                context.restoreGState()
            }
        }
        else if let image = normalDotImage {
            for dot in normalDots {
                image.draw(in: dot.frame)
            }
        }
        
        //draw highlighted dots
        if let drawDotClosure = drawDotWithContext {
            for dot in highlightedDots {
                context.saveGState()
                drawDotClosure(dot, context)
                context.restoreGState()
            }
        }
        else if let image = highlightedDotImage {
            for dot in highlightedDots {
                image.draw(in: dot.frame)
            }
        }
    }
}

// MARK: - Record Line Path
extension HUIPatternLockView {
    private func normalDotContainsPoint(_ point: CGPoint) -> Dot? {
        for dot in normalDots {
            if dot.frame.contains(point) {
                return dot
            }
        }
        return nil
    }
    
    internal func updateLinePathWithPoint(_ point: CGPoint) -> Void {
        let linePathPointsCount = linePath.count
        
        if var dot = normalDotContainsPoint(point) {
            if (linePathPointsCount <= 0) {
                //if no any points in linePath. use this dot's center to be the linePath start and end point
                linePath.append(dot.center)
                linePath.append(dot.center)
            }
            else {
                //else insert a new point into the path
                linePath.insert(dot.center, at: linePathPointsCount-1)
            }
            
            //mark this dot as highlighted
            dot.highlighted = true
            highlightedDots.append(dot);
            normalDots.remove(at: normalDots.index(of: dot)!)
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
    
    internal func endLinePathWithPoint(_ point: CGPoint) -> Void {
        if var dot = normalDotContainsPoint(point) {
            dot.highlighted = true
            highlightedDots.append(dot)
            normalDots.remove(at: normalDots.index(of: dot)!)
        }
        
        linePath = highlightedDots.map({ (dot: Dot) -> CGPoint in
            return dot.center
        })
    }
}

// MARK: - Touches
extension HUIPatternLockView {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else {
            return
        }
        
        resetDotsState()
        updateLinePathWithPoint(point)
        setLockViewNeedUpdate(needRecalculateDotsFrame: false)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else {
            return
        }
        
        updateLinePathWithPoint(point)
        setLockViewNeedUpdate(needRecalculateDotsFrame: false)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !highlightedDots.isEmpty else {
            return
        }
        
        guard let point = touches.first?.location(in: self) else {
            return
        }
        
        endLinePathWithPoint(point)
        setLockViewNeedUpdate(needRecalculateDotsFrame: false)
        
        //get password and call back
        let dotCounts = highlightedDots.count
        var currentPassword = String()
        for dot in highlightedDots {
            currentPassword.append("[\(dot.tag)]")
        }
        if let callback = didDrawPatternWithPassword {
            callback(self, dotCounts, currentPassword)
        }
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetDotsState()
        setLockViewNeedUpdate(needRecalculateDotsFrame: false)
    }
}

// MARK: - HUIPatternLockView.Dot: Equatable
public func ==(lhs: HUIPatternLockView.Dot, rhs: HUIPatternLockView.Dot) -> Bool {
    return (lhs.tag == rhs.tag && lhs.frame.equalTo(rhs.frame))
}

