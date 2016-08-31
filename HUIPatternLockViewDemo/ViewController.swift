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
    internal func configuareLockViewWithImages() {
        let defaultLineColor = HUIPatternLockView.defaultLineColor
        let correctLineColor = UIColor.green
        let wrongLineColor = UIColor.red
        
        let normalImage = UIImage(named: "dot_normal")
        let highlightedImage = UIImage(named: "dot_highlighted")
        let correctImage = highlightedImage?.tintImage(tintColor: correctLineColor)
        let wrongImage = highlightedImage?.tintImage(tintColor: wrongLineColor)
        
        
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
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
    
    internal func configuareLockViewWithCustomDrawingCodes() {
        lockView.drawLinePathWithContext = { [unowned self] (path, context) -> Void in
            self.drawLockViewLinePath(path, context: context)
        }
        
        lockView.drawDotWithContext = { [unowned self] (dot, context) -> Void in
            self.drawLockViewDot(dot, context: context)
        }
        
        lockView.didDrawPatternWithPassword = { [unowned self] (lockView, count, password) -> Void in
            self.handleLockViewDidDrawPassword(lockView: lockView, count: count, password: password)
        }
    }
    
    private func colorForLockViewState(_ state: LockViewPasswordState, useHighlightedColor: Bool) -> UIColor {
        switch state {
        case .Correct:
            return UIColor.green
        case .Wrong:
            return UIColor.red
        default:
            if useHighlightedColor {
                return HUIPatternLockView.defaultLineColor
            }
            else {
                return UIColor.black
            }
        }
    }
    
    private func resetLockView(_ lockView: HUIPatternLockView) {
        lockView.resetDotsState()
        lockView.drawLinePathWithContext = { [unowned self] (path, context) -> Void in
            self.drawLockViewLinePath(path, context: context)
        }
        lockView.drawDotWithContext = { [unowned self] (dot, context) -> Void in
            self.drawLockViewDot(dot, context: context)
        }
        lockView.isUserInteractionEnabled = true
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
        lockView.isUserInteractionEnabled = false
        lockView.drawLinePathWithContext = { [unowned self] (path, context) -> Void in
            self.drawLockViewLinePath(path, context: context, state: state)
        }
        lockView.drawDotWithContext = { [unowned self] (dot, context) -> Void in
            self.drawLockViewDot(dot, context: context, state: state)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.resetLockView(lockView)
        }
    }
    
    private func drawLockViewLinePath(_ path: Array<CGPoint>, context: CGContext?, state: LockViewPasswordState = .Normal) {
        guard !path.isEmpty else {
            return
        }
        
        guard let context = context else {
            return
        }
        
        let color = colorForLockViewState(state, useHighlightedColor: true)
        let dashLengths: [CGFloat] = [5.0, 10.0, 5.0]
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(3.0)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.setLineDash(phase: 0.0, lengths: dashLengths)
        
        let fistPoint = path.first
        for point in path {
            if point == fistPoint {
                context.move(to: point)
            }
            else {
                context.addLine(to: point)
            }
        }
        
        context.drawPath(using: .stroke)
    }
    
    private func drawLockViewDot(_ dot: HUIPatternLockView.Dot, context: CGContext?, state: LockViewPasswordState = .Normal) {
        guard let context = context else {
            return
        }
        
        let dotCenter = dot.center
        let innerDotRadius: CGFloat = 15.0
        let color = colorForLockViewState(state, useHighlightedColor: dot.highlighted)
        
        context.setLineWidth(1.0)
        context.setFillColor(color.cgColor)
        context.setStrokeColor(color.cgColor)
        
        context.move(to: dotCenter)
        context.beginPath()
        context.addArc(center: dotCenter, radius: innerDotRadius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        context.closePath()
        context.fillPath()
        context.strokeEllipse(in: dot.frame)
    }
}

extension UIImage {
    public func tintImage(tintColor: UIColor) -> UIImage? {
        return tintImage(tintColor, blendMode: .destinationIn)
    }
    
    public func gradientTintImage(tintColor: UIColor) -> UIImage? {
        return tintImage(tintColor, blendMode: .overlay)
    }
    
    public func tintImage(_ tintColor: UIColor, blendMode: CGBlendMode) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let bounds = CGRect(origin: CGPoint.zero, size: size)
        tintColor.setFill()
        UIRectFill(bounds)
        
        draw(in: bounds, blendMode: blendMode, alpha: 1.0)
        
        //draw again to save alpha channel
        if blendMode != .destinationIn {
            draw(in: bounds, blendMode: .destinationIn, alpha: 1.0)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

