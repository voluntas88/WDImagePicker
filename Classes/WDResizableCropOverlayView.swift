//
//  WDResizableCropOverlayView.swift
//  WDImagePicker
//
//  Created by Wu Di on 27/8/15.
//  Copyright (c) 2015 Wu Di. All rights reserved.
//

import UIKit

private struct WDResizableViewBorderMultiplyer {
    var widthMultiplyer: CGFloat!
    var heightMultiplyer: CGFloat!
    var xMultiplyer: CGFloat!
    var yMultiplyer: CGFloat!
}

internal class WDResizableCropOverlayView: WDImageCropOverlayView {
    private let kBorderCorrectionValue: CGFloat = 12

    var contentView: UIView!
    var cropBorderView: WDCropBorderView!

    private var initialContentSize = CGSize(width: 0, height: 0)
    private var resizingEnabled: Bool!
    private var anchor: CGPoint!
    private var startPoint: CGPoint!
    private var resizeMultiplyer = WDResizableViewBorderMultiplyer()

    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            
            let width = bounds.size.width
            let height = bounds.size.height

            contentView?.frame = CGRectMake((
                width - initialContentSize.width) / 2,
                (height - WDImagePicker.toolbarHeight - initialContentSize.height) / 2,
                initialContentSize.width,
                initialContentSize.height)

            cropBorderView?.frame = CGRectMake(
                (width - initialContentSize.width) / 2 - kBorderCorrectionValue,
                (height - WDImagePicker.toolbarHeight - initialContentSize.height) / 2 - kBorderCorrectionValue,
                initialContentSize.width + kBorderCorrectionValue * 2,
                initialContentSize.height + kBorderCorrectionValue * 2)
        }
    }

    init(frame: CGRect, initialContentSize: CGSize) {
        super.init(frame: frame)

        self.initialContentSize = initialContentSize
        addContentViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchPoint = touch.locationInView(cropBorderView)

            anchor = calculateAnchorBorder(touchPoint)
            fillMultiplyer()
            resizingEnabled = true
            startPoint = touch.locationInView(superview)
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            if (resizingEnabled != nil) {
                resizeWithTouchPoint(touch.locationInView(superview))
            }
        }
    }

    override func drawRect(rect: CGRect) {
        //fill outer rect
        UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).set()
        UIRectFill(bounds)

        //fill inner rect
        UIColor.clearColor().set()
        UIRectFill(contentView.frame)
    }

    private func addContentViews() {
        let width = bounds.size.width
        let height = bounds.size.height

        contentView = UIView(frame: CGRectMake((
            width - initialContentSize.width) / 2,
            (height - WDImagePicker.toolbarHeight - initialContentSize.height) / 2,
            initialContentSize.width,
            initialContentSize.height))
        contentView.backgroundColor = UIColor.clearColor()
        cropSize = contentView.frame.size
        addSubview(contentView)

        cropBorderView = WDCropBorderView(frame: CGRectMake(
            (width - initialContentSize.width) / 2 - kBorderCorrectionValue,
            (height - WDImagePicker.toolbarHeight - initialContentSize.height) / 2 - kBorderCorrectionValue,
            initialContentSize.width + kBorderCorrectionValue * 2,
            initialContentSize.height + kBorderCorrectionValue * 2))
        addSubview(cropBorderView)
    }

    private func calculateAnchorBorder(anchorPoint: CGPoint) -> CGPoint {
        let allHandles = getAllCurrentHandlePositions()
        var closest: CGFloat = 3000
        var anchor: CGPoint!

        for handlePoint in allHandles {
            // Pythagoras is watching you :-)
            let xDist = handlePoint.x - anchorPoint.x
            let yDist = handlePoint.y - anchorPoint.y
            let dist = sqrt(xDist * xDist + yDist * yDist)

            closest = dist < closest ? dist : closest
            anchor = closest == dist ? handlePoint : anchor
        }

        return anchor
    }

    private func getAllCurrentHandlePositions() -> [CGPoint] {
        let leftX: CGFloat = 0
        let rightX = cropBorderView.bounds.size.width
        let centerX = leftX + (rightX - leftX) / 2

        let topY: CGFloat = 0
        let bottomY = cropBorderView.bounds.size.height
        let middleY = topY + (bottomY - topY) / 2

        // starting with the upper left corner and then following the rect clockwise
        let topLeft = CGPointMake(leftX, topY)
        let topCenter = CGPointMake(centerX, topY)
        let topRight = CGPointMake(rightX, topY)
        let middleRight = CGPointMake(rightX, middleY)
        let bottomRight = CGPointMake(rightX, bottomY)
        let bottomCenter = CGPointMake(centerX, bottomY)
        let bottomLeft = CGPointMake(leftX, bottomY)
        let middleLeft = CGPointMake(leftX, middleY)

        return [topLeft, topCenter, topRight, middleRight, bottomRight, bottomCenter, bottomLeft,
            middleLeft]
    }

    private func resizeWithTouchPoint(point: CGPoint) {
        // This is the place where all the magic happends
        // prevent goint offscreen...
        let border = kBorderCorrectionValue * 2
        var pointX = point.x < border ? border : point.x
        var pointY = point.y < border ? border : point.y
        pointX = pointX > superview!.bounds.size.width - border ?
            superview!.bounds.size.width - border : pointX
        pointY = pointY > superview!.bounds.size.height - border ?
            superview!.bounds.size.height - border : pointY

        let heightChange = (pointY - startPoint.y) * resizeMultiplyer.heightMultiplyer
        let widthChange = (startPoint.x - pointX) * resizeMultiplyer.widthMultiplyer
        let xChange = -1 * widthChange * resizeMultiplyer.xMultiplyer
        let yChange = -1 * heightChange * resizeMultiplyer.yMultiplyer

        var newFrame =  CGRectMake(
            cropBorderView.frame.origin.x + xChange,
            cropBorderView.frame.origin.y + yChange,
            cropBorderView.frame.size.width + widthChange,
            cropBorderView.frame.size.height + heightChange);
        newFrame = preventBorderFrameFromGettingTooSmallOrTooBig(newFrame)
        resetFrame(to: newFrame)
        startPoint = CGPointMake(pointX, pointY)
    }

    private func preventBorderFrameFromGettingTooSmallOrTooBig(frameRect: CGRect) -> CGRect {
        let toolbarSize = WDImagePicker.toolbarHeight
        var newFrame = frameRect

        if newFrame.size.width < 64 {
            newFrame.size.width = cropBorderView.frame.size.width
            newFrame.origin.x = cropBorderView.frame.origin.x
        }
        if newFrame.size.height < 64 {
            newFrame.size.height = cropBorderView.frame.size.height
            newFrame.origin.y = cropBorderView.frame.origin.y
        }

        if newFrame.origin.x < 0 {
            newFrame.size.width = cropBorderView.frame.size.width +
                (cropBorderView.frame.origin.x - superview!.bounds.origin.x)
            newFrame.origin.x = 0
        }

        if newFrame.origin.y < 0 {
            newFrame.size.height = cropBorderView.frame.size.height +
                (cropBorderView.frame.origin.y - superview!.bounds.origin.y)
            newFrame.origin.y = 0
        }

        if newFrame.size.width + newFrame.origin.x > frame.size.width {
            newFrame.size.width = frame.size.width - cropBorderView.frame.origin.x
        }

        if newFrame.size.height + newFrame.origin.y > frame.size.height - toolbarSize {
            newFrame.size.height = frame.size.height -
                cropBorderView.frame.origin.y - toolbarSize
        }

        return newFrame
    }

    private func resetFrame(to frame: CGRect) {
        cropBorderView.frame = frame
        contentView.frame = CGRectInset(frame, kBorderCorrectionValue, kBorderCorrectionValue)
        cropSize = contentView.frame.size
        setNeedsDisplay()
        cropBorderView.setNeedsDisplay()
    }

    private func fillMultiplyer() {
        // -1 left, 0 middle, 1 right
        resizeMultiplyer.heightMultiplyer = anchor.y == 0 ?
            -1 : anchor.y == cropBorderView.bounds.size.height ? 1 : 0
        // -1 up, 0 middle, 1 down
        resizeMultiplyer.widthMultiplyer = anchor.x == 0 ?
            1 : anchor.x == cropBorderView.bounds.size.width ? -1 : 0
        // 1 left, 0 middle, 0 right
        resizeMultiplyer.xMultiplyer = anchor.x == 0 ? 1 : 0
        // 1 up, 0 middle, 0 down
        resizeMultiplyer.yMultiplyer = anchor.y == 0 ? 1 : 0
    }
}