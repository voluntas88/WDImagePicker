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
    fileprivate override func layoutSubviews() {
        super.layoutSubviews()

        if let zoomView = delegate?.viewForZooming?(in: self) {
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
    fileprivate var resizableCropArea = false

    fileprivate var scrollView: UIScrollView!
    fileprivate var imageView: UIImageView!
    fileprivate var cropOverlayView: WDImageCropOverlayView!
    fileprivate var xOffset: CGFloat!
    fileprivate var yOffset: CGFloat!

    fileprivate static func scaleRect(_ rect: CGRect, scale: CGFloat) -> CGRect {
        return CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.size.width * scale,
            height: rect.size.height * scale)
    }

    fileprivate var imageToCrop: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }

    fileprivate var cropSize: CGSize {
        get {
            return cropOverlayView.cropSize
        }
        set {
            if let view = cropOverlayView {
                view.cropSize = newValue
            } else {
                if resizableCropArea {
                    cropOverlayView = WDResizableCropOverlayView(frame: bounds,
                        initialContentSize: CGSize(width: newValue.width, height: newValue.height))
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

        isUserInteractionEnabled = true
        backgroundColor = UIColor.black
        scrollView = ScrollView(frame: frame)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        scrollView.decelerationRate = 0
        scrollView.backgroundColor = UIColor.clear
        addSubview(scrollView)

        imageView = UIImageView(frame: scrollView.frame)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black
        scrollView.addSubview(imageView)

        scrollView.minimumZoomScale =
            scrollView.frame.width / scrollView.frame.height
        scrollView.maximumZoomScale = 20
        scrollView.setZoomScale(1.0, animated: false)
        self.resizableCropArea = resizableCropArea
        self.imageToCrop = imageToCrop
        self.cropSize = cropSize
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !resizableCropArea {
            return scrollView
        }

        if let resizableCropView = cropOverlayView as? WDResizableCropOverlayView {
            if resizableCropView.cropBorderView.frame.insetBy(dx: -10, dy: -10).contains(point) {
                
                let cropBorderSize = resizableCropView.cropBorderView.frame.size
                if cropBorderSize.width < 60 || cropBorderSize.height < 60 {
                    return super.hitTest(point, with: event)
                }
                
                if resizableCropView.cropBorderView.frame.insetBy(dx: 30, dy: 30).contains(point) {
                    return scrollView
                }
                
                if resizableCropView.cropBorderView.frame.insetBy(dx: -10, dy: -10).contains(point) {
                    return super.hitTest(point, with: event)
                }
                
                return super.hitTest(point, with: event)
            }
        }

        return scrollView
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let size = cropSize;
        xOffset = floor((bounds.width - size.width) * 0.5)
        yOffset = floor((bounds.height - WDImagePicker.toolbarHeight - size.height) * 0.5)
        
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
            scrollView.frame = CGRect(x: xOffset, y: yOffset, width: size.width, height: size.height)
            scrollView.contentSize = CGSize(width: size.width, height: size.height)
            imageView.frame = CGRect(x: 0, y: floor((size.height - factoredHeight) * 0.5),
                                         width: factoredWidth, height: factoredHeight)
        }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func croppedImage() -> UIImage? {
        // Calculate rect that needs to be cropped
        var visibleRect = resizableCropArea ? calcVisibleRectForResizeableCropArea() : calcVisibleRectForCropArea()
        if let imageToCrop = imageToCrop {
            // transform visible rect to image orientation
            visibleRect = visibleRect.applying(orientationTransformedRectOfImage(imageToCrop));
            if let imageRef = imageToCrop.cgImage?.cropping(to: visibleRect) {
                // finally crop image
                return UIImage(cgImage: imageRef, scale: imageToCrop.scale, orientation: imageToCrop.imageOrientation)
            }
        }
        return nil
    }

    fileprivate func calcVisibleRectForResizeableCropArea() -> CGRect {
        if let resizableView = cropOverlayView as? WDResizableCropOverlayView {
            // first of all, get the size scale by taking a look at the real image dimensions. Here it
            // doesn't matter if you take the width or the hight of the image, because it will always
            // be scaled in the exact same proportion of the real image
            var sizeScale = imageView.image!.size.width / imageView.frame.size.width
            sizeScale *= scrollView.zoomScale
            
            // then get the postion of the cropping rect inside the image
            var visibleRect = resizableView.contentView.convert(resizableView.contentView.bounds,
                                                                    to: imageView)
            visibleRect = WDImageCropView.scaleRect(visibleRect, scale: sizeScale)
            
            return visibleRect
        }

        return CGRect.zero
    }

    fileprivate func calcVisibleRectForCropArea() -> CGRect {
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
            var visibleRect = scrollView.convert(scrollView.bounds, to:imageView)
            visibleRect = WDImageCropView.scaleRect(visibleRect, scale: scale)
            
            return visibleRect
        }
        return CGRect.zero
    }

    fileprivate func orientationTransformedRectOfImage(_ image: UIImage) -> CGAffineTransform {
        switch image.imageOrientation {
        case .left:
            return CGAffineTransform(rotationAngle: CGFloat(M_PI_2)).translatedBy(x: 0, y: -image.size.height)
        case .right:
            return CGAffineTransform(rotationAngle: CGFloat(-M_PI_2)).translatedBy(x: -image.size.width, y: 0)
        case .down:
            return CGAffineTransform(rotationAngle: CGFloat(-M_PI)).translatedBy(x: -image.size.width, y: -image.size.height)
        default:
            return CGAffineTransform.identity
        }
    }
}
