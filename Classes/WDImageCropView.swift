//
//  WDImageCropView.swift
//  WDImagePicker
//
//  Created by Wu Di on 27/8/15.
//  Copyright (c) 2015 Wu Di. All rights reserved.
//

import UIKit
import QuartzCore

private class ScrollView: UIScrollView {
    private override func layoutSubviews() {
        super.layoutSubviews()

        if let zoomView = delegate?.viewForZoomingInScrollView?(self) {
            let boundsSize = bounds.size
            var frameToCenter = zoomView.frame

            // center horizontally
            if frameToCenter.size.width < boundsSize.width {
                frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
            } else {
                frameToCenter.origin.x = 0
            }

            // center vertically
            if frameToCenter.size.height < boundsSize.height {
                frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
            } else {
                frameToCenter.origin.y = 0
            }

            zoomView.frame = frameToCenter
        }
    }
}

internal class WDImageCropView: UIView, UIScrollViewDelegate {
    private var resizableCropArea = false

    private var scrollView: UIScrollView!
    private var imageView: UIImageView!
    private var cropOverlayView: WDImageCropOverlayView!
    private var xOffset: CGFloat!
    private var yOffset: CGFloat!

    private static func scaleRect(rect: CGRect, scale: CGFloat) -> CGRect {
        return CGRectMake(
            rect.origin.x * scale,
            rect.origin.y * scale,
            rect.size.width * scale,
            rect.size.height * scale)
    }

    private var imageToCrop: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }

    private var cropSize: CGSize {
        get {
            return cropOverlayView.cropSize
        }
        set {
            if let view = cropOverlayView {
                view.cropSize = newValue
            } else {
                if resizableCropArea {
                    cropOverlayView = WDResizableCropOverlayView(frame: bounds,
                        initialContentSize: CGSizeMake(newValue.width, newValue.height))
                } else {
                    cropOverlayView = WDImageCropOverlayView(frame: bounds)
                }
                cropOverlayView.cropSize = newValue
                addSubview(cropOverlayView)
            }
        }
    }

    init(frame: CGRect, resizableCropArea:Bool, imageToCrop:UIImage, cropSize: CGSize) {
        super.init(frame: frame)

        userInteractionEnabled = true
        backgroundColor = UIColor.blackColor()
        scrollView = ScrollView(frame: frame)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        scrollView.decelerationRate = 0
        scrollView.backgroundColor = UIColor.clearColor()
        addSubview(scrollView)

        imageView = UIImageView(frame: scrollView.frame)
        imageView.contentMode = .ScaleAspectFit
        imageView.backgroundColor = UIColor.blackColor()
        scrollView.addSubview(imageView)

        scrollView.minimumZoomScale =
            CGRectGetWidth(scrollView.frame) / CGRectGetHeight(scrollView.frame)
        scrollView.maximumZoomScale = 20
        scrollView.setZoomScale(1.0, animated: false)
        self.resizableCropArea = resizableCropArea
        self.imageToCrop = imageToCrop
        self.cropSize = cropSize
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if !resizableCropArea {
            return scrollView
        }

        if let resizableCropView = cropOverlayView as? WDResizableCropOverlayView {
            if CGRectContainsPoint(CGRectInset(resizableCropView.cropBorderView.frame, -10, -10), point) {
                
                let cropBorderSize = resizableCropView.cropBorderView.frame.size
                if cropBorderSize.width < 60 || cropBorderSize.height < 60 {
                    return super.hitTest(point, withEvent: event)
                }
                
                if CGRectContainsPoint(CGRectInset(resizableCropView.cropBorderView.frame, 30, 30), point) {
                    return scrollView
                }
                
                if CGRectContainsPoint(CGRectInset(resizableCropView.cropBorderView.frame, -10, -10), point) {
                    return super.hitTest(point, withEvent: event)
                }
                
                return super.hitTest(point, withEvent: event)
            }
        }

        return scrollView
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let size = cropSize;
        xOffset = floor((CGRectGetWidth(bounds) - size.width) * 0.5)
        yOffset = floor((CGRectGetHeight(bounds) - WDImagePicker.toolbarHeight - size.height) * 0.5)
        
        if let imageToCrop = imageToCrop {
            let height = imageToCrop.size.height
            let width = imageToCrop.size.width
            
            var factor: CGFloat = 0
            var factoredHeight: CGFloat = 0
            var factoredWidth: CGFloat = 0
            
            if width > height {
                factor = width / size.width
                factoredWidth = size.width
                factoredHeight =  height / factor
            } else {
                factor = height / size.height
                factoredWidth = width / factor
                factoredHeight = size.height
            }
            cropOverlayView.frame = bounds
            scrollView.frame = CGRectMake(xOffset, yOffset, size.width, size.height)
            scrollView.contentSize = CGSizeMake(size.width, size.height)
            imageView.frame = CGRectMake(0, floor((size.height - factoredHeight) * 0.5),
                                         factoredWidth, factoredHeight)
        }
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func croppedImage() -> UIImage? {
        // Calculate rect that needs to be cropped
        var visibleRect = resizableCropArea ? calcVisibleRectForResizeableCropArea() : calcVisibleRectForCropArea()
        if let imageToCrop = imageToCrop {
            // transform visible rect to image orientation
            visibleRect = CGRectApplyAffineTransform(visibleRect, orientationTransformedRectOfImage(imageToCrop));
            if let imageRef = CGImageCreateWithImageInRect(imageToCrop.CGImage, visibleRect) {
                // finally crop image
                return UIImage(CGImage: imageRef, scale: imageToCrop.scale, orientation: imageToCrop.imageOrientation)
            }
        }
        return nil
    }

    private func calcVisibleRectForResizeableCropArea() -> CGRect {
        if let resizableView = cropOverlayView as? WDResizableCropOverlayView {
            // first of all, get the size scale by taking a look at the real image dimensions. Here it
            // doesn't matter if you take the width or the hight of the image, because it will always
            // be scaled in the exact same proportion of the real image
            var sizeScale = imageView.image!.size.width / imageView.frame.size.width
            sizeScale *= scrollView.zoomScale
            
            // then get the postion of the cropping rect inside the image
            var visibleRect = resizableView.contentView.convertRect(resizableView.contentView.bounds,
                                                                    toView: imageView)
            visibleRect = WDImageCropView.scaleRect(visibleRect, scale: sizeScale)
            
            return visibleRect
        }

        return CGRectZero
    }

    private func calcVisibleRectForCropArea() -> CGRect {
        if let imageToCrop = imageToCrop {
            // scaled width/height in regards of real width to crop width
            let scaleWidth = imageToCrop.size.width / cropSize.width
            let scaleHeight = imageToCrop.size.height / cropSize.height
            var scale: CGFloat = 0
            
            if cropSize.width == cropSize.height {
                scale = max(scaleWidth, scaleHeight)
            } else if cropSize.width > cropSize.height {
                scale = imageToCrop.size.width < imageToCrop.size.height ?
                    max(scaleWidth, scaleHeight) :
                    min(scaleWidth, scaleHeight)
            } else {
                scale = imageToCrop.size.width < imageToCrop.size.height ?
                    min(scaleWidth, scaleHeight) :
                    max(scaleWidth, scaleHeight)
            }
            
            // extract visible rect from scrollview and scale it
            var visibleRect = scrollView.convertRect(scrollView.bounds, toView:imageView)
            visibleRect = WDImageCropView.scaleRect(visibleRect, scale: scale)
            
            return visibleRect
        }
        return CGRectZero
    }

    private func orientationTransformedRectOfImage(image: UIImage) -> CGAffineTransform {
        switch image.imageOrientation {
        case .Left:
            return CGAffineTransformTranslate(
                CGAffineTransformMakeRotation(CGFloat(M_PI_2)), 0, -image.size.height)
        case .Right:
            return CGAffineTransformTranslate(
                CGAffineTransformMakeRotation(CGFloat(-M_PI_2)),-image.size.width, 0)
        case .Down:
            return CGAffineTransformTranslate(
                CGAffineTransformMakeRotation(CGFloat(-M_PI)),
                -image.size.width, -image.size.height)
        default:
            return CGAffineTransformIdentity
        }
    }
}