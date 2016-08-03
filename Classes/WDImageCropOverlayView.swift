//
//  WDImageCropOverlayView.swift
//  WDImagePicker
//
//  Created by Wu Di on 27/8/15.
//  Copyright (c) 2015 Wu Di. All rights reserved.
//

import UIKit

internal class WDImageCropOverlayView: UIView {

    var cropSize: CGSize!

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.clearColor()
        userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        backgroundColor = UIColor.clearColor()
        userInteractionEnabled = true
    }

    override func drawRect(rect: CGRect) {
        let width = CGRectGetWidth(frame)
        let height = CGRectGetHeight(frame) - WDImagePicker.toolbarHeight

        let heightSpan = floor(height / 2 - cropSize.height / 2)
        let widthSpan = floor(width / 2 - cropSize.width / 2)

        // fill outer rect
        UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).set()
        UIRectFill(bounds)

        // fill inner border
        UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).set()
        UIRectFrame(CGRectMake(widthSpan - 2, heightSpan - 2, cropSize.width + 4,
            cropSize.height + 4))

        // fill inner rect
        UIColor.clearColor().set()
        UIRectFill(CGRectMake(widthSpan, heightSpan, cropSize.width, cropSize.height))
    }
}
